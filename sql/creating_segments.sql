-- see comment below
\set create_donor_sum_directly false

drop materialized view donor_sum;
drop materialized view indiv_group;

/*
 *  Parse out comma- and space-delimited "components" (first/middle/last names, titles, suffixes,
 *  etc.) of the `name` field for `indiv`
 *
 *  Terminology-wise, "parts" are comma-delimited components, and "words" are delimited by either
 *  commas or spaces; note that commas and spaces should be trimmed and normalized by this point,
 *  but we still trim the parts here to be sure (and there are some other possible outlier cases
 *  as well, see scripts/fmt_indiv.awk)
 */
create or replace view indiv_parsed as
select id,
       name,
       city,
       state,
       zip_code,
       array_length(name_parts, 1) num_parts,
       array_length(name_words, 1) num_words,
       nullif(trim(name_parts[1]), '') as part1,
       nullif(trim(name_parts[2]), '') as part2,
       nullif(trim(name_parts[3]), '') as part3,
       nullif(trim(array_to_string(name_parts[4:], ',')), '') as other_parts,
       array_length(regexp_split_to_array(trim(name_parts[1]), '\s+'), 1) as part1_words,
       array_length(regexp_split_to_array(trim(name_parts[2]), '\s+'), 1) as part2_words,
       array_length(regexp_split_to_array(trim(name_parts[3]), '\s+'), 1) as part3_words
  from (select i.id,
               i.name,
               i.city,
               i.state,
               i.zip_code,
               string_to_array(i.name, ',') as name_parts,
               regexp_split_to_array(i.name, '[\s,]+') as name_words
          from indiv i) as name_segments;

\if :create_donor_sum_directly
    /*
     *  for some unknown reason, the following construction is giving the database
     *  engine (PostgreSQL 10.10) lots of problems (it sometimes works, but most
     *  of the time a parallel read spins the disk up to 100% and the query never
     *  returns)...
     */
    create materialized view donor_sum as
    select ip.part1                  as last_name,
           substr(ip.part2, 1, 3)    as first_name_pfx,
           substr(ip.zip_code, 1, 3) as zip_pfx,
           count(distinct ip.id)     as indivs,
           array_agg(distinct ip.id) as indiv_ids,
           count(ic.transaction_amt) as contribs,
           sum(ic.transaction_amt)   as total_amt,
           round(sum(ic.transaction_amt) / count(ic.transaction_amt), 2)
                                     as avg_amt
      from indiv_parsed ip
      join indiv_contrib ic on ic.indiv_id = ip.id
     where ip.name ~ '^[A-Z].'
       and ip.zip_code is not null
       and ip.num_parts > 1
       and ip.part1 !~ ' '
     group by 1, 2, 3;
\else
    /*
     *  ...so we have to break this thing into two steps (kind of stupid, but seems
     *   to work reliably)
     */
    create materialized view indiv_group as
    select ip.part1                  as last_name,
           substr(ip.part2, 1, 3)    as first_name_pfx,
           substr(ip.zip_code, 1, 3) as zip_pfx,
           count(distinct ip.id)     as indivs,
           array_agg(distinct ip.id) as indiv_ids
      from indiv_parsed ip
     where ip.name ~ '^[A-Z].'
       and ip.zip_code is not null
       and ip.num_parts > 1
       and ip.part1 !~ ' '
     group by 1, 2, 3;

    /*
     *  Not sure whether it is better to re-aggregate the unnested ids (even though
     *  we are not able to omit the `distinct` qualifier), or select `ig.indiv_ids`
     *  and add to GROUP BY clause--voting for the former option right now
     */
    create materialized view donor_sum as
    with indiv_group_memb as (
        select ig.last_name,
               ig.first_name_pfx,
               ig.zip_pfx,
               --ig.indiv_ids,
               unnest(ig.indiv_ids) as indiv_id
          from indiv_group ig
    )
    select igm.last_name,
           igm.first_name_pfx,
           igm.zip_pfx,
           array_agg(distinct igm.indiv_id)
                                     as indiv_ids,
           count(ic.transaction_amt) as contribs,
           sum(ic.transaction_amt)   as total_amt,
           round(sum(ic.transaction_amt) / count(ic.transaction_amt), 2)
                                     as avg_amt
      from indiv_group_memb igm
      join indiv_contrib ic on ic.indiv_id = igm.indiv_id
     group by 1, 2, 3;
\endif

create index donor_sum_total_amt on donor_sum (total_amt);
create index donor_sum_avg_amt   on donor_sum (avg_amt);

select count(*) as num_donors,
       sum(total_amt) as sum_total_amt
  from donor_sum
\gset

select :num_donors, :sum_total_amt;

with seg_def as (
    select unnest(array[100000000,
                        50000000,
                        10000000,
                        1000000,
                        500000,
                        100000,
                        50000,
                        10000,
                        5000,
                        2500,
                        1000,
                        500,
                        0]) as seg_amt
)
select seg_def.seg_amt,
       seg_stat.donors,
       seg_stat.pct_donors,
       seg_stat.pct_total_amt
  from seg_def
  join lateral
       (select count(*)                                           as donors,
               round(count(*)::numeric / :num_donors * 100, 2)    as pct_donors,
               round(sum(ds.total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
          from donor_sum ds
         where ds.total_amt > seg_def.seg_amt) as seg_stat on true;

/*
 *  Utility function to help with naming of segments
 */
CREATE OR REPLACE FUNCTION human_readable(label TEXT) RETURNS TEXT AS $$
    SELECT regexp_replace(
               regexp_replace(
                   regexp_replace(
                       label,
                       '0{9}([^0-9]|$)', 'B\1'),
                   '0{6}([^0-9]|$)', 'M\1'),
               '0{3}([^0-9]|$)', 'K\1');
$$ LANGUAGE SQL;

/*
 *  Now we create donor segments for sample records within each segment, and also
 *  connect the `indiv` records for each donor to a base indivual record
 */
CREATE OR REPLACE FUNCTION create_donor_seg_by_amt(seg_amt NUMERIC, seg_size INTEGER = 100)
RETURNS TABLE(seg_id BIGINT, seg_name TEXT) AS $$
DECLARE
sql      TEXT;
seg_name TEXT;
seg_desc TEXT = NULL;
BEGIN
    sql = format('select human_readable(concat(%L, $1, %L))', '$', '+ donors');
    EXECUTE sql INTO seg_name USING seg_amt;

    sql = 'with donor_set as (
               select row(ds.indiv_ids)::id_array as ids
                 from donor_sum ds
                where ds.total_amt > $2
                order by ds.total_amt asc
                limit ($3)
           )
           select create_donor_seg(array_agg(ids), $1),
                  $1
             from donor_set
            group by 2';
    RETURN QUERY EXECUTE sql USING seg_name, seg_amt, seg_size;
END;
$$ LANGUAGE plpgsql;

with seg_def as (
    select unnest(array[100000000,
                        50000000,
                        10000000,
                        1000000,
                        500000,
                        100000,
                        50000,
                        10000,
                        5000,
                        2500,
                        1000,
                        500,
                        0]) as seg_amt
)
select seg_def.seg_amt, (create_donor_seg_by_amt(seg_def.seg_amt)).*
  from seg_def;

select ds.id    as seg_id,
       ds.name  as seg_name,
       count(*) as seg_members
  from donor_seg ds
  join donor_seg_memb dsm on dsm.donor_seg_id = ds.id
 group by 1, 2
 order by 1;

with seg_donors as (
    select dsm.donor_indiv_id
      from donor_seg ds
      join donor_seg_memb dsm on dsm.donor_seg_id = ds.id
     where ds.name = '$50M+ donors'
)
select i.id,
       i.name,
       i.city,
       i.state,
       i.zip_code
  from seg_donors sd
  join indiv i on i.id = sd.donor_indiv_id
 order by i.name, i.zip_code;

with seg_donors as (
    select dsm.donor_indiv_id
      from donor_seg ds
      join donor_seg_memb dsm on dsm.donor_seg_id = ds.id
     where ds.name = '$50M+ donors'
)
select i.id,
       i.name,
       i.city,
       i.state,
       i.zip_code
  from seg_donors sd
  join indiv i on i.donor_indiv_id = sd.donor_indiv_id
 order by i.name, i.zip_code;

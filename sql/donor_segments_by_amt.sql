-- see comment below
\set create_donor_sum_directly false

drop materialized view donor_sum;
drop materialized view donor_base;

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
     *  for some unknown reason, the following construction is giving the databse
     *  engine (PostgreSQL 10.10) lots of problems (it sometimes works, but most
     *  of the time a parallel read spins the disk up to 100% and never returns),
     *  so we break this into two steps (kind of stupid, but works reliably)
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
    create materialized view donor_base as
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
     *  we are not able to omit the `distinct` qualifier), or select `db.indiv_ids`
     *  and add to GROUP BY clause--voting for the former option right now
     */
    create materialized view donor_sum as
    with donor_base_indiv as (
        select db.last_name,
               db.first_name_pfx,
               db.zip_pfx,
               --db.indiv_ids,
               unnest(db.indiv_ids) as indiv_id
          from donor_base db
    )
    select dbi.last_name,
           dbi.first_name_pfx,
           dbi.zip_pfx,
           array_agg(distinct dbi.indiv_id)
                                     as indiv_ids,
           count(ic.transaction_amt) as contribs,
           sum(ic.transaction_amt)   as total_amt,
           round(sum(ic.transaction_amt) / count(ic.transaction_amt), 2)
                                     as avg_amt
      from donor_base_indiv dbi
      join indiv_contrib ic on ic.indiv_id = dbi.indiv_id
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
 *  Now we create groups for sample records within each segment, and also
 *  connect the `indiv` records for each donor to a "base" indivual
 */

\ir create_indiv_functions.sql

CREATE OR REPLACE FUNCTION create_seg(seg_amt numeric, group_name text, group_desc text = null)
RETURNS BIGINT AS $$
DECLARE
indiv_tbl TEXT = 'indiv';
donor_sum RECORD;
group_id  BIGINT;
base_id   BIGINT;
BEGIN
    EXECUTE 'insert into indiv_group (name, description)
             values ($1, $2)
             returning id'
    INTO group_id
    USING group_name, group_desc;

    FOR donor_sum IN
        EXECUTE
            'select last_name,
                    first_name_pfx,
                    zip_pfx,
                    indiv_ids,
                    contribs,
                    total_amt,
                    avg_amt
               from donor_sum
              where total_amt > $1
              order by total_amt asc
              limit 100'
        USING seg_amt
    LOOP
        EXECUTE 'select set_base_indiv($1, $2)'
        INTO base_id
        USING indiv_tbl, donor_sum.indiv_ids;

        EXECUTE
            'insert into indiv_group_memb(indiv_group_id, base_indiv_id)
             values ($1, $2)
             on conflict do nothing'
        USING group_id, base_id;
    END LOOP;
    RETURN group_id;
END;
$$ LANGUAGE plpgsql;

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
       seg_group.group_name,
       seg_group.group_id
  from seg_def
  join lateral
       (select human_readable(concat('$', seg_def.seg_amt, '+ donors')) as seg_name)
       as seg_desc on true
  join lateral
       (select seg_desc.seg_name                              as group_name,
               create_seg(seg_def.seg_amt, seg_desc.seg_name) as group_id)
       as seg_group on true;
*/

CREATE OR REPLACE FUNCTION create_donor_seg_by_amt(seg_amt NUMERIC)
RETURNS TABLE(seg_amt NUMERIC, group_name TEXT, group_id BIGINT) AS $$
    select seg_amt,
           seg_group.group_name,
           seg_group.group_id
      from (select human_readable(concat('$', seg_amt, '+ donors')) as seg_name)
           as seg_info
      join lateral
           (select seg_info.seg_name                      as group_name,
                   create_seg(seg_amt, seg_info.seg_name) as group_id)
           as seg_group on true;
$$ LANGUAGE SQL;

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
select (create_donor_seg_by_amt(seg_def.seg_amt)).*
  from seg_def;

select g.id     as group_id,
       g.name   as group_name,
       count(*) as group_members
  from indiv_group g
  join indiv_group_memb gm on gm.indiv_group_id = g.id
 group by 1, 2
 order by 1;

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

/*
 *  for some unknown reason, the following construction is giving the databse
 *  engine (PostgreSQL 10.10) lots of problems (it sometimes works, but most
 *  of the time a parallel read spins the disk up to 100% and never returns),
 *  so we break this into two steps (kind of stupid, but works reliably)
 */
/*
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
*/

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
 group by 1, 2, 3

/*
 *  Not sure whether it is better to re-aggregate the unnested ids (in which case,
 *  we can at least omit the `distinct` qualifier), or select `db.indiv_ids` and
 *  add to GROUP BY clause--voting for the former option right now
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
       array_agg(dbi.indiv_id)   as indiv_ids,
       count(ic.transaction_amt) as contribs,
       sum(ic.transaction_amt)   as total_amt,
       round(sum(ic.transaction_amt) / count(ic.transaction_amt), 2)
                                 as avg_amt
  from donor_base_indiv dbi
  join indiv_contrib ic on ic.indiv_id = dbi.indiv_id
 group by 1, 2, 3;

create index donor_sum_total_amt on donor_sum (total_amt);
create index donor_sum_avg_amt   on donor_sum (avg_amt);

select count(*) as num_donors,
       sum(total_amt) as sum_total_amt
  from donor_sum
\gset

select :num_donors, :sum_total_amt;

/*
 *  Donor summary - Over $100,000,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 100000000;

/*
 *  Donor summary - Over $50,000,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 50000000;

/*
 *  Donor summary - Over $10,000,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 10000000;

/*
 *  Donor summary - Over $1,000,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 1000000;

/*
 *  Donor summary - Over $500,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 500000;

/*
 *  Donor summary - Over $100,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 100000;

/*
 *  Donor summary - Over $50,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 50000;

/*
 *  Donor summary - Over $10,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 10000;

/*
 *  Donor summary - Over $5,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 5000;

/*
 *  Donor summary - Over $2,500
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 2500;

/*
 *  Donor summary - Over $1,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 1000;

/*
 *  Donor summary - Over $1,000
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum
 where total_amt > 500;

/*
 *  Donor Summary - Totals
 */
select count(*),
       round(count(*)::numeric / :num_donors * 100, 2) as pct_donors,
       round(sum(total_amt) / :sum_total_amt * 100, 1) as pct_total_amt
  from donor_sum;

/*
 *  Now we create groups for sample records within each segment, and also
 *  connect the `indiv` records for each donor to a "base" indivual
 */

/*
 *  Over $100,000,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 100000000
 order by total_amt asc;

/*
 *  Over $50,000,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 50000000
 order by total_amt asc;

/*
 *  Over $10,000,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 10000000
 order by total_amt asc
 limit 50;

/*
 *  Over $1,000,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 1000000
 order by total_amt asc
 limit 100;

/*
 *  Over $500,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 500000
 order by total_amt asc
 limit 100;

/*
 *  Over $100,000
 */
select last_name,
       first_name_pfx,
       zip_pfx,
       indiv_ids,
       contribs,
       total_amt,
       avg_amt
  from donor_sum
 where total_amt > 100000
 order by total_amt asc
 limit 100;

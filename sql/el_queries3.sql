/*
 *  EL Topic 3
 *
 *    - I am curious to see giving lives of people.
 *
 *    - I have noticed in a lot of my research thus far that people tend to get involved
 *      at some point and then after that point continuously donate a lot of money.
 *
 *    - I'm wondering if there is something that could link the upticks together.
 */

/*
 *  Clear the previous context, if it exists (allow the current context to persist
 *  after the script is run); it's okay if any of these fail because the view does
 *  not exist (but not okay if there is a dependency requiring CASCADE)
 *
 *  Note: if/when we do this right, we won't have to drop and recreate these views
 *  (at least not the "_contrib" ones), but rather just refresh them based on some
 *  higher-level context specification
 */
drop materialized view if exists donor_contrib;
drop materialized view if exists donor_def;
drop materialized view if exists hh_contrib;
drop materialized view if exists hh_def;

/*
 *  Create views we need (TODO: make permanent in the schema, when we have finalized
 *  the design of "indiv" vs "donor", representation of "household", etc.)
 */
create or replace view donor_indiv as
select *
  from indiv
 where id = donor_indiv_id;

create or replace view hh_indiv as
select *
  from indiv
 where id = hh_indiv_id;

/*
 *  These two views are used to validate the integrity of the `donor_indiv_id` and
 *  `hh_indiv_id` foreign keys (no rows returned indicates that the key points to
 *  a well-formed "donor" or "hh" indiv record), since we don't have any other real
 *  enforcement mechanism currently in the management of the keys
 */
create or replace view bad_donor_indiv_ids as
select i.*
  from indiv i
  join indiv donor_i
       on donor_i.id = i.donor_indiv_id
 where donor_i.donor_indiv_id != donor_i.id;

create or replace view bad_hh_indiv_ids as
select i.*
  from indiv i
  join indiv hh
       on hh.id = i.hh_indiv_id
 where hh.hh_indiv_id != hh.id;

/*
 *  Create household for working set identified in `el_queries1.sql`
 */
with indiv_set as (
    select i.*
      from indiv i
     where i.name like 'SANDELL, %'
       and i.zip_code ~ '9402[58]'
)
update indiv
   set hh_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `hh_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select hh.id,
       hh.name,
       hh.city,
       hh.state,
       hh.zip_code
  from hh_indiv hh
 where hh.name like 'SANDELL, %'
   and hh.zip_code ~ '9402[58]';

select *
  from hh_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  Connect `indiv` records together for the first individual (more active donor)
 *  in the household; note that the choice of `min(id)` as the `hh_indiv_id` is
 *  arbitrary, we can actually pick any one from the set
 */
with indiv_set as (
    select i.*
      from hh_indiv hh
      join indiv i on i.hh_indiv_id = hh.id
                   and (i.name ~ 'SCOTT' and i.name !~ 'MRS\.')
     where hh.name = 'SANDELL, JENNIFER'
)
update indiv
   set donor_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `donor_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select d.id,
       d.name,
       d.city,
       d.state,
       d.zip_code
  from hh_indiv hh
  join donor_indiv d
       on d.hh_indiv_id = hh.id
       and (d.name ~ 'SCOTT' and d.name !~ 'MRS\.')
 where hh.name = 'SANDELL, JENNIFER';

select *
  from donor_indiv
 where name = 'SANDELL, SCOTT';

/*
 *  Connect `indiv` records together for the second individual in the household;
 *  note that this actually includes all of the remaining household individuals,
 *  but it is a reasonable conjecture that it all represents the same person in
 *  this case
 */
with indiv_set as (
    select i.*
      from hh_indiv hh
      join indiv i on i.hh_indiv_id = hh.id
                   and not (i.name ~ 'SCOTT' and i.name !~ 'MRS\.')
     where hh.name = 'SANDELL, JENNIFER'
)
update indiv
   set donor_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `donor_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select d.id,
       d.name,
       d.city,
       d.state,
       d.zip_code
  from hh_indiv hh
  join donor_indiv d
       on d.hh_indiv_id = hh.id
       and not (d.name ~ 'SCOTT' and d.name !~ 'MRS\.')
 where hh.name = 'SANDELL, JENNIFER';

select *
  from donor_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  Now validate that the `hh_indiv_id` and `donor_indiv_id` keys are all good
 *  (count should be zero for both queries)
 */
select count(*)
  from bad_hh_indiv_ids;

select count(*)
  from bad_donor_indiv_ids;

/*
 *  Need to re-analyze the tables to let the optimizer know there is now data in the
 *  `hh_indiv_id` and `donor_indiv_id` columns
 */
analyze indiv;

/*
 *  Now let's repeat the query from `el_queries1.sql` for household contributions by
 *  election cycle), but using `hh_indiv`, to validate the `hh_indiv_id`s--should
 *  yield the exact same results
 */
with hh_def as (
    select *
      from hh_indiv
     where name = 'SANDELL, JENNIFER'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  For fun (and to validate `donor_indiv`), let's break out contributions made by
 *  the first individual (more active donor) in the household
 */
with donor_def as (
    select *
      from donor_indiv
     where name = 'SANDELL, SCOTT'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from donor_def d
  join indiv i on i.donor_indiv_id = d.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  And now, the same for the second individual (these two queries should add up to
 *  the household result, above)
 */
with donor_def as (
    select *
      from donor_indiv
     where name = 'SANDELL, JENNIFER'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from donor_def d
  join indiv i on i.donor_indiv_id = d.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  Okay, now that we have the `hh_def` and `donor_def` CTEs verified, we can look at
 *  patterns of contribution from the household (and later, the individuals)
 *
 *  We will now specify the "context" for the following sequence of queries (i.e. the
 *  household, and later the individual, being examined) using a materialized view; we
 *  could also continue using a CTE for this, but it gets a little cumbersome (not
 *  that there is a real performance penalty for doing so)
 */
create materialized view hh_def as
select *
  from hh_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  First, here's an aggregate summary of the household contributions
 */
select hh.id                   as hh_id,
       hh.name                 as hh_name,
       hh.zip_code             as hh_zip_code,
       count(distinct i.id)    as hh_indivs,
       count(*)                as num_contribs,
       min(ic.transaction_dt)  as first_contrib,
       max(ic.transaction_dt)  as last_contrib,
       sum(ic.transaction_amt) as total_amt,
       round(avg(ic.transaction_amt), 2) as avg_amt
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1, 2, 3
 order by 2;

/*
 *  And also a breakout by election cycle
 */
select hh.id                   as hh_id,
       hh.name                 as hh_name,
       hh.zip_code             as hh_zip_code,
       ic.elect_cycle          as elect_cycle,
       count(distinct i.id)    as hh_indivs,
       count(*)                as num_contribs,
       min(ic.transaction_dt)  as first_contrib,
       max(ic.transaction_dt)  as last_contrib,
       sum(ic.transaction_amt) as total_amt,
       round(avg(ic.transaction_amt), 2) as avg_amt
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1, 2, 3, 4
 order by 2, 4;

/*
 *  Now let's get the list of all individual contributions from this household ordered
 *  by date, just to get a qualitative feel for the data
 */
select ic.id              as contrib_id,
       ic.transaction_dt  as contrib_dt,
       ic.transaction_amt as contrib_amt,
       i.id               as donor_id,
       i.name             as donor_name,
       cmte.cmte_nm       as cmte_nm
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 order by 2;

/*
 *  Note that there are a handful of puzzling/suspect contributions in the previous result
 *  (i.e. multiple contributions from an individual to the same committee on the same day);
 *  as mentioned before, the accounting and reporting practices that underlie this data set
 *  need to be understood in order to ascertain and improve the accuracy of the analysis
 *
 *  For now, let's try and isolate some of the dubious contribution data.  You can further
 *  drill down on any of the items returned here using the following:
 *
 *      SELECT *
 *        FROM indiv_contrib
 *       WHERE id in (<contrib_ids>);
 *
 *  where <contrib_ids> is the comma-separated list of ids in the result set
 */
select ic.transaction_dt  as contrib_dt,
       count(*)           as contribs,
       array_agg(ic.id)   as contrib_ids,
       array_agg(ic.transaction_amt) as contrib_amts,
       i.id               as donor_id,
       i.name             as donor_name,
       cmte.cmte_id       as cmte_id,
       cmte.cmte_nm       as cmte_nm
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1, 5, 6, 7, 8
having count(*) > 1
 order by 1;

/*
 *  For now, we'll aggregate the contributions by date (dubiousness and all), since we
 *  are doing a time-based analysis here, as well as aggregating across donors within
 *  the household here (we can report by individual separately/later)
 *
 *  We create a materialized view for reuse
 */
create materialized view hh_contrib as
select ic.transaction_dt       as contrib_dt,
       sum(ic.transaction_amt) as contrib_amt,
       count(*)                as contribs,
       count(distinct i.name)  as donors,
       array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
       array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
  from hh_def hh
  join indiv i on i.hh_indiv_id = hh.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1;

/*
 *  Let's look at the data
 */
select *
  from hh_contrib
 order by contrib_dt;

/*
 *  Let's add in the interval between contributions and relative amount (plus/minus
 *  compared to the previous contribution)
 */
select hhc.contrib_dt,
       hhc.contrib_amt,
       hhc.cmte_ids,
       hhc.cmte_nms,
       hhc.contrib_dt - prev.contrib_dt as interval_days,
       hhc.contrib_amt - prev.contrib_amt as relative_amt
  from hh_contrib hhc
  left join lateral
       (select *
          from hh_contrib hhc2
         where hhc2.contrib_dt < hhc.contrib_dt
         order by hhc2.contrib_dt desc
         limit 1
       ) as prev on true
 order by 1;

/*
 *  And now we'll add some cumulative stats (commenting out the committee ID and name,
 *  for readability--you can refer to the previous result set for correlation)
 */
select hhc.contrib_dt,
       hhc.contrib_amt,
       --hhc.cmte_ids,
       --hhc.cmte_nms,
       hhc.contrib_dt - prev.contrib_dt           as interval_days,
       round(cumul.elapsed_days::numeric / cumul.intervals, 1)
                                                  as cumul_avg_intv,
       hhc.contrib_amt - prev.contrib_amt         as relative_amt,
       cumul.total_amt                            as cumul_total_amt,
       round(cumul.total_amt / cumul.contribs, 2) as cumul_avg_amt
  from hh_contrib hhc
  left join lateral
       (select *
          from hh_contrib hhc2
         where hhc2.contrib_dt < hhc.contrib_dt
         order by hhc2.contrib_dt desc
         limit 1
       ) as prev on true
  left join lateral
       (select count(*)                as contribs,
               nullif(count(*) - 1, 0) as intervals,
               sum(hhc3.contrib_amt)   as total_amt,
               max(hhc3.contrib_dt) - min(hhc3.contrib_dt)
                                       as elapsed_days
          from hh_contrib hhc3
         where hhc3.contrib_dt <= hhc.contrib_dt
       ) as cumul on true
 order by 1;

/*
 *  To demonstrate the extensibility of this approach, we'll define a materialized
 *  view for the more active donor in the household (based on the CTE used above),
 *  and execute the same query showing differential/cumulative contribution stats
 *
 *  Note that we are using the same pattern here for `donor_def` and `donor_contrib`
 *  (using materialized views vs. CTEs) as with the household queries above
 */
create materialized view donor_def as
select *
  from donor_indiv
 where name = 'SANDELL, SCOTT';

create materialized view donor_contrib as
select ic.transaction_dt       as contrib_dt,
       sum(ic.transaction_amt) as contrib_amt,
       count(*)                as contribs,
       count(distinct i.name)  as donors,
       array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
       array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
  from donor_def d
  join indiv i on i.donor_indiv_id = d.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1;

select bc.contrib_dt,
       bc.contrib_amt,
       --bc.cmte_ids,
       --bc.cmte_nms,
       bc.contrib_dt - prev.contrib_dt            as interval_days,
       round(cumul.elapsed_days::numeric / cumul.intervals, 1)
                                                  as cumul_avg_intv,
       bc.contrib_amt - prev.contrib_amt          as relative_amt,
       cumul.total_amt                            as cumul_total_amt,
       round(cumul.total_amt / cumul.contribs, 2) as cumul_avg_amt
  from donor_contrib bc
  left join lateral
       (select *
          from donor_contrib bc2
         where bc2.contrib_dt < bc.contrib_dt
         order by bc2.contrib_dt desc
         limit 1
       ) as prev on true
  left join lateral
       (select count(*)                as contribs,
               nullif(count(*) - 1, 0) as intervals,
               sum(bc3.contrib_amt)    as total_amt,
               max(bc3.contrib_dt) - min(bc3.contrib_dt)
                                       as elapsed_days
          from donor_contrib bc3
         where bc3.contrib_dt <= bc.contrib_dt
       ) as cumul on true
 order by 1;

/*
 *  TODO:
 *    - Progression by election cycle (individual cycle and cumulative stats)
 */

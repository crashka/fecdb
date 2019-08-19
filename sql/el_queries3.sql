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
 *  Ensure the views we need are in place
 */
\ir create_views_indiv_master.sql

select table_catalog,
       table_schema,
       table_name
  from information_schema.views
 where table_name in ('base_indiv', 'hhh_indiv', 'bad_base_indiv_ids', 'bad_hhh_indiv_ids');

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
   set hhh_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `hhh_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select hhh.id,
       hhh.name,
       hhh.city,
       hhh.state,
       hhh.zip_code
  from hhh_indiv hhh
 where hhh.name like 'SANDELL, %'
   and hhh.zip_code ~ '9402[58]';

select *
  from hhh_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  Connect `indiv` records together for the first individual (more active donor)
 *  in the household; note that the choice of `min(id)` as the `hhh_indiv_id` is
 *  arbitrary, we can actually pick any one from the set
 */
with indiv_set as (
    select i.*
      from hhh_indiv hhh
      join indiv i on i.hhh_indiv_id = hhh.id
                   and (i.name ~ 'SCOTT' and i.name !~ 'MRS\.')
     where hhh.name = 'SANDELL, JENNIFER'
)
update indiv
   set base_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `base_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select base.id,
       base.name,
       base.city,
       base.state,
       base.zip_code
  from hhh_indiv hhh
  join base_indiv base
       on base.hhh_indiv_id = hhh.id
       and (base.name ~ 'SCOTT' and base.name !~ 'MRS\.')
 where hhh.name = 'SANDELL, JENNIFER';

select *
  from base_indiv
 where name = 'SANDELL, SCOTT';

/*
 *  Connect `indiv` records together for the second individual in the household;
 *  note that this actually includes all of the remaining household individuals,
 *  but it is a reasonable conjecture that it all represents the same person in
 *  this case
 */
with indiv_set as (
    select i.*
      from hhh_indiv hhh
      join indiv i on i.hhh_indiv_id = hhh.id
                   and not (i.name ~ 'SCOTT' and i.name !~ 'MRS\.')
     where hhh.name = 'SANDELL, JENNIFER'
)
update indiv
   set base_indiv_id = (select min(id) from indiv_set)
 where id in (select id from indiv_set);

/*
 *  Verify the `base_indiv` record just created, and validate that we can identify
 *  it uniquely by `name` (both queries here should return exactly one row)
 */
select base.id,
       base.name,
       base.city,
       base.state,
       base.zip_code
  from hhh_indiv hhh
  join base_indiv base
       on base.hhh_indiv_id = hhh.id
       and not (base.name ~ 'SCOTT' and base.name !~ 'MRS\.')
 where hhh.name = 'SANDELL, JENNIFER';

select *
  from base_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  Now validate that the `hhh_indiv_id` and `base_indiv_id` keys are all good
 *  (count should be zero for both queries)
 */
select count(*)
  from bad_hhh_indiv_ids;

select count(*)
  from bad_base_indiv_ids;

/*
 *  Need to re-analyze the tables to let the optimizer know there is now data in the
 *  `hhh_indiv_id` and `base_indiv_id` columns
 */
analyze indiv;

/*
 *  Now let's repeat the query from `el_queries1.sql` for household contributions by
 *  election cycle), but using `hhh_indiv`, to validate the `hhh_indiv_id`s--should
 *  yield the exact same results
 */
with hhh_def as (
    select *
      from hhh_indiv
     where name = 'SANDELL, JENNIFER'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  For fun (and to validate `base_indiv`), let's break out contributions made by
 *  the first individual (more active donor) in the household
 */
with base_def as (
    select *
      from base_indiv
     where name = 'SANDELL, SCOTT'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from base_def base
  join indiv i on i.base_indiv_id = base.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  And now, the same for the second individual (these two queries should add up to
 *  the household result, above)
 */
with base_def as (
    select *
      from base_indiv
     where name = 'SANDELL, JENNIFER'
)
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from base_def base
  join indiv i on i.base_indiv_id = base.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1
 order by 1;

/*
 *  Okay, now that we have the `hhh_def` and `base_def` CTEs verified, we can look at
 *  patterns of contribution from the household (and later, the individuals)
 *
 *  We will now specify the "context" for the following sequence of queries (i.e. the
 *  household, and later the individual, being examined) using a materialized view; we
 *  could also continue using a CTE for this, but it gets a little cumbersome (not
 *  that there is a real performance penalty for doing so)
 */
create materialized view hhh_def as
select *
  from hhh_indiv
 where name = 'SANDELL, JENNIFER';

/*
 *  First, here's an aggregate summary of the household contributions
 */
select hhh.id                  as hhh_id,
       hhh.name                as hhh_name,
       hhh.zip_code            as hhh_zip_code,
       count(distinct i.id)    as hhh_indivs,
       count(*)                as num_contribs,
       min(ic.transaction_dt)  as first_contrib,
       max(ic.transaction_dt)  as last_contrib,
       sum(ic.transaction_amt) as total_amt,
       round(avg(ic.transaction_amt), 2) as avg_amt
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
  join indiv_contrib ic on ic.indiv_id = i.id
 group by 1, 2, 3
 order by 2;

/*
 *  And also a breakout by election cycle
 */
select hhh.id                  as hhh_id,
       hhh.name                as hhh_name,
       hhh.zip_code            as hhh_zip_code,
       ic.elect_cycle          as elect_cycle,
       count(distinct i.id)    as hhh_indivs,
       count(*)                as num_contribs,
       min(ic.transaction_dt)  as first_contrib,
       max(ic.transaction_dt)  as last_contrib,
       sum(ic.transaction_amt) as total_amt,
       round(avg(ic.transaction_amt), 2) as avg_amt
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
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
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
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
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
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
 */
select ic.transaction_dt       as contrib_dt,
       sum(ic.transaction_amt) as contrib_amt,
       count(*)                as contribs,
       count(distinct i.name)  as donors,
       array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
       array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
  from hhh_def hhh
  join indiv i on i.hhh_indiv_id = hhh.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1
 order by 1;

/*
 *  Let's add in the interval between contributions and relative amount (plus/minus
 *  compared to the previous contribution)
 *
 *  note that we could also define a materialized view for `hh_contrib`, but we are
 *  only using it twice between now and the end of the script, so we won't bother
 */
with hh_contrib as (
    select ic.transaction_dt       as contrib_dt,
           sum(ic.transaction_amt) as contrib_amt,
           count(*)                as contribs,
           count(distinct i.name)  as donors,
           array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
           array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
      from hhh_def hhh
      join indiv i on i.hhh_indiv_id = hhh.id
      join indiv_contrib ic on ic.indiv_id = i.id
      left join cmte
           on cmte.cmte_id = ic.cmte_id
           and cmte.elect_cycle = ic.elect_cycle
     group by 1
     order by 1
)
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
with hh_contrib as (
    select ic.transaction_dt       as contrib_dt,
           sum(ic.transaction_amt) as contrib_amt,
           count(*)                as contribs,
           count(distinct i.name)  as donors,
           array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
           array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
      from hhh_def hhh
      join indiv i on i.hhh_indiv_id = hhh.id
      join indiv_contrib ic on ic.indiv_id = i.id
      left join cmte
           on cmte.cmte_id = ic.cmte_id
           and cmte.elect_cycle = ic.elect_cycle
     group by 1
     order by 1
)
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
 *  Note that we are using the same pattern here for `base_def` and `base_contrib`
 *  (in terms of CTE vs. materialized view) as with the household queries above
 */
create materialized view base_def as
select *
  from base_indiv
 where name = 'SANDELL, SCOTT';

with base_contrib as (
    select ic.transaction_dt       as contrib_dt,
           sum(ic.transaction_amt) as contrib_amt,
           count(*)                as contribs,
           count(distinct i.name)  as donors,
           array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
           array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
      from base_def base
      join indiv i on i.base_indiv_id = base.id
      join indiv_contrib ic on ic.indiv_id = i.id
      left join cmte
           on cmte.cmte_id = ic.cmte_id
           and cmte.elect_cycle = ic.elect_cycle
     group by 1
     order by 1
)
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
  from base_contrib bc
  left join lateral
       (select *
          from base_contrib bc2
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
          from base_contrib bc3
         where bc3.contrib_dt <= bc.contrib_dt
       ) as cumul on true
 order by 1;

/*
 *  Clear the current context
 */
drop materialized view hhh_def;
drop materialized view base_def;

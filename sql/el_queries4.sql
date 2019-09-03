/*
 *  EL Topic 4
 *
 *    - I think similarly being able to graph sets of people or individuals' amount
 *      giving per cycle would be interesting.
 *
 *    - In the 2 year cycle when does a specific person tend to give (eg: when should
 *      we call them)?
 *
 *    - Are big donors or infrequent donors more likely to give in off years?
 */

/*
 *  Cleanup previous context, if it exists (drop in reverse order due to dependencies);
 *  it's okay if any of these fail because the view does not exist (but not if there is
 *  a dependency requiring CASCADE)
 */
drop materialized view donor_ec_sum;
drop materialized view donor_ec_contrib;
drop materialized view donor_ec_def;  -- see note below (creation of materialized view)

/*
 *  Let's use the following "donor" record as a stand-in while we develop the queries for
 *  reporting the timing of giving with a cycle; later we can replace `donor_ec_def` with
 *  a donor segment
 *
 *  Note that this is not a good name (`donor_def` is better), but doing it this way to
 *  decouple this script from `el_queries3.sql`
 */
create materialized view donor_ec_def as
select *
  from donor_indiv
 where name = 'SANDELL, SCOTT';

/*
 *  This view rerepsents all of the contributions from the party/parties specified by
 *  `donor_ec_def`; note that multiple contributions on a given day (if/when it happens)
 *  are lumped together as `contrib_dt`, to make the overall reporting simpler
 */
create materialized view donor_ec_contrib as
select ic.elect_cycle                                           as elect_cycle,
       ic.transaction_dt                                        as contrib_dt,
       sum(ic.transaction_amt)                                  as contrib_amt,
       count(*)                                                 as contribs,
       count(distinct i.name)                                   as donors,
       array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
       array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
  from donor_ec_def d
  join indiv i on i.donor_indiv_id = d.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1, 2;

/*
 *  Aggregate the previous data by election cycle, showing the earliest and latest
 *  contributions for each cycle; note that "days_rel" means days relative to the
 *  election date for the cycle (it goes without saying that negative is "before"
 *  the date, and positive is "after")
 */
create materialized view donor_ec_sum as
select ec.key                                    as key,
       ec.election_day                           as election_day,
       count(*)                                  as contrib_dates,
       sum(bec.contrib_amt)                      as total_amt,
       round(sum(bec.contrib_amt) / count(*), 2) as avg_amt,
       min(bec.contrib_dt)                       as earliest,
       max(bec.contrib_dt)                       as latest,
       min(bec.contrib_dt) - ec.election_day     as erly_days_rel,
       max(bec.contrib_dt) - ec.election_day     as late_days_rel
  from donor_ec_contrib bec
  join election_cycle ec on ec.key = bec.elect_cycle
 group by 1, 2;

/*
 *  Let's look at the data we just isolated, for visual inspection--first, the individual
 *  contributions (we can add a LIMIT to the query when working with larger segements)
 */
select *
  from donor_ec_contrib
 order by 1, 2;

/*
 *  And next, the contribution aggregates by election cycle
 */
select *
  from donor_ec_sum
 order by 1;

/*
 *  For each of the contributions in `donor_ec_contrib`, we now show the following:
 *    - cycle_pct       : percentage of the total for the cycle
 *    - cumul_cycle_amt : cumulative amount for the cycle
 *    - cumul_cycle_pct : cumulative percentage for the cycle
 *    - days_rel        : days before/after election date
 *
 *  This is the kind of stuff that would be interesting to show on a scatter
 *  plot (coming shortly, with Jupyter integration)
 */
select bec.elect_cycle,
       bec.contrib_dt,
       bec.contrib_amt                   as total_amt,
       round(bec.contrib_amt / bes.total_amt * 100.0, 1)
                                         as cycle_pct,
       cumul.total_amt                   as cumul_cycle_amt,
       round(cumul.total_amt / bes.total_amt * 100.0, 1)
                                         as cumul_cycle_pct,
       bec.contrib_dt - bes.election_day as days_rel
  from donor_ec_contrib bec
  join donor_ec_sum bes on bes.key = bec.elect_cycle
  left join lateral
       (select count(*)                as contribs,
               nullif(count(*) - 1, 0) as intervals,
               sum(bec2.contrib_amt)   as total_amt,
               max(bec2.contrib_dt) - min(bec2.contrib_dt)
                                       as elapsed_days
          from donor_ec_contrib bec2
         where bec2.elect_cycle = bec.elect_cycle
           and bec2.contrib_dt <= bec.contrib_dt
       ) as cumul on true
 order by 1, 2;

/*
 *  TODO:
 *    - Highlight election years vs. off-years
 *    - Cumulative and by person
 *    - Pattern for reporting/analyzing by donor and by segment
 *        - Performance considerations by size of segment
 */

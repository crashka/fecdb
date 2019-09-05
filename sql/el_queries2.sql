/*
 *  EL Topic 2
 *
 *    - I want to be able to see people who have donated to 314 and other things
 *      they have donated to predict who might be likely to donate to 314.
 */

/*
 *  Clear the previous context, if it exists (allow the current context to persist
 *  after the script is run)
 */
drop materialized view if exists top_314_donors;

/*
 *  Create a view to represent `indiv_contrib` records associated with any committee
 *  whose name is prefixed by "314" (this can be amended if there are other patterns
 *  representing the same PAC; currently there are no others with "314" elsewhere in
 *  the name)
 *
 *  Note that this serves as a template for creating other segments of contributions,
 *  and hence the donors (actually, just "individuals" for now) behind them, for doing
 *  a similar type of investigation
 */
create or replace view contrib_to_314 as
select cm.cmte_nm,
       ic.*
  from cmte cm
  join indiv_contrib ic
       on ic.cmte_id = cm.cmte_id
 where cm.cmte_nm like '314%';

/*
 *  Let's start by building working set for top 50 contributors to 314 (all time)
 *
 *  Note that this materialized view can just be refreshed (rather than dropped and
 *  recreated) if `contrib_to_314` (definition of 314-related PACs) is amended (see
 *  note above)
 */
create materialized view top_314_donors as
select i.id as indiv_id,
       i.name as donor,
       i.city,
       i.state,
       i.zip_code,
       count(*) as "314_contribs",
       sum(ct.transaction_amt) as total_314_amt,
       round(avg(ct.transaction_amt), 2) as avg_314_amt,
       array_agg(distinct ct.elect_cycle) as "314_elect_cycles"
  from indiv i
  join contrib_to_314 ct
       on ct.indiv_id = i.id
 group by 1, 2, 3, 4, 5
 order by 7 desc, 6 desc
 limit 50;

/*
 *  Let's take a look at the data for the top 314 donors
 */
select *
  from top_314_donors
 order by total_314_amt desc, "314_contribs" desc;

/*
 *  Now let's get a summary (count and total/average amount) of other contributions
 *  from top 314 contributors
 *
 *  Note that this query can be simplified by specifying "cm.cmte_nm not like '314%'"
 *  in the join clause for `cmte` (and hence omitting the anti-join for `ic`), but
 *  that would be cheating, since we're not really supposed to know (and rely on)
 *  the underlying definition of the `contrib_to_314` view
 */
select td.indiv_id,
       td.donor,
       td.city,
       td.state,
       td.zip_code,
       td.total_314_amt,
       td."314_elect_cycles",
       count(distinct cm.cmte_nm) as other_cmtes,
       count(*) as other_contribs,
       sum(ic.transaction_amt) as total_other_amt,
       round(avg(ic.transaction_amt), 2) as avg_other_amt
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2, 3, 4, 5, 6, 7
 order by 10 desc, 2 asc;

/*
 *  Let's take a look at the actual other committees that 314 contributors gave to
 *  (across all years); we'll look at the ones with over $100,000 total contribution
 *  from this group
 */
select cm.cmte_nm as committee,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt,
       array_agg(distinct ic.elect_cycle) as cmte_elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1
having sum(ic.transaction_amt) >= 100000
 order by 3 desc, 1 asc;

/*
 *  Now, the largest aggregate contributions by donors to specific committees in the
 *  previous set (cutoff here is $50,000)
 */
select cm.cmte_nm as committee,
       td.donor,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt,
       array_agg(distinct ic.elect_cycle) as cmte_elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2
having sum(ic.transaction_amt) >= 50000
 order by 4 desc, 2 asc;

/*
 *  Same as previous, but adding in election cycle (cutoff is $25,000)
 */
select cm.cmte_nm as committee,
       td.donor,
       ic.elect_cycle,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2, 3
having sum(ic.transaction_amt) >= 25000
 order by 5 desc, 2 asc, 3 asc;

/*
 *  Here's a repeat of the previous few queries, but only looking at contributions in
 *  election cycles coincident with contributions to 314
 *
 *  First, the summary (count and total/average amount) of other contributions from
 *  top 314 contributors (only including election cycles in which they gave to 314)
 */
select td.indiv_id,
       td.donor,
       td.city,
       td.state,
       td.zip_code,
       td.total_314_amt,
       td."314_elect_cycles",
       count(distinct cm.cmte_nm) as other_cmtes,
       count(*) as other_contribs,
       sum(ic.transaction_amt) as total_other_amt,
       round(avg(ic.transaction_amt), 2) as avg_other_amt
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and ic.elect_cycle = any (td."314_elect_cycles")
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2, 3, 4, 5, 6, 7
 order by 10 desc, 2 asc;

/*
 *  Next, the individual committees (for election cycles in which the donor made a 314
 *  contribution)
 */
select cm.cmte_nm as committee,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt,
       array_agg(distinct ic.elect_cycle) as cmte_elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and ic.elect_cycle = any (td."314_elect_cycles")
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1
having sum(ic.transaction_amt) >= 100000
 order by 3 desc, 1 asc;

/*
 *  Now, the largest aggregate contributions by donors to specific committees in the
 *  previous set (for election cycles in which the donor made a 314 contribution)
 */
select cm.cmte_nm as committee,
       td.donor,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt,
       array_agg(distinct ic.elect_cycle) as cmte_elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and ic.elect_cycle = any (td."314_elect_cycles")
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2
having sum(ic.transaction_amt) >= 50000
 order by 4 desc, 2 asc;

/*
 *  Same as previous, but adding in election cycle (again, only those in which the
 *  donor made a 314 contribution)
 */
select cm.cmte_nm as committee,
       td.donor,
       ic.elect_cycle,
       count(*) as cmte_contribs,
       sum(ic.transaction_amt) as total_cmte_amt,
       round(avg(ic.transaction_amt), 2) as avg_cmte_amt
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
       and ic.elect_cycle = any (td."314_elect_cycles")
       and not exists
       (select *
          from contrib_to_314 c314
         where c314.id = ic.id)
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 group by 1, 2, 3
having sum(ic.transaction_amt) >= 25000
 order by 5 desc, 2 asc, 3 asc;

/*
 *  And here are the top 314 contributors who didn't give to other committees at all
 *  (as far as we can tell, with the individual master record correlations)
 *
 *  Note on SQL: in olden times, I might have written this using a left outer join
 *  on `ic` with "ic.id is null" as a WHERE predicate, since "...WHERE NOT EXISTS..."
 *  anti-joins were not optimized, but that would be slower now (not that it matters
 *  much in this context), since all joined rows would have to be processed
 */
select td.indiv_id,
       td.donor,
       td.city,
       td.state,
       td.zip_code,
       td."314_contribs",
       td.total_314_amt,
       td."314_elect_cycles"
  from top_314_donors td
 where not exists
       (select *
          from indiv_contrib ic
         where ic.indiv_id = td.indiv_id
           and not exists
               (select *
                  from contrib_to_314 c314
                 where c314.id = ic.id)
       )
 order by 7 desc, 6 desc;

/*
 *  And those who didn't give to other committees in years they gave to 314
 */
select td.indiv_id,
       td.donor,
       td.city,
       td.state,
       td.zip_code,
       td."314_contribs",
       td.total_314_amt,
       td."314_elect_cycles"
  from top_314_donors td
 where not exists
       (select *
          from indiv_contrib ic
         where ic.indiv_id = td.indiv_id
           and ic.elect_cycle = any (td."314_elect_cycles")
           and not exists
               (select *
                  from contrib_to_314 c314
                 where c314.id = ic.id)
       )
 order by 7 desc, 6 desc;

/*
 *  Now, here's the bad news...there are some anomalies in the data set that
 *  need to be understood in order for any query results to be trusted and/or
 *  rectified.  In particular, there are a number of negative contributions,
 *  espeically among the largest donors and receiving committees.
 *
 *  First, negative contributions to committees...
 */
select cm.cmte_nm as committee,
       count(*) as neg_contribs,
       sum(ic.transaction_amt) as total_neg_amt,
       min(ic.transaction_amt) as min_neg_amt,
       round(avg(ic.transaction_amt), 2) as avg_neg_amt,
       array_agg(distinct ic.elect_cycle) as elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 where ic.transaction_amt < 0
 group by 1
 order by 3 asc;

/*
 *  And, negative contributions from donors...
 */
select td.donor,
       count(*) as neg_contribs,
       sum(ic.transaction_amt) as total_neg_amt,
       min(ic.transaction_amt) as min_neg_amt,
       round(avg(ic.transaction_amt), 2) as avg_neg_amt,
       array_agg(distinct ic.elect_cycle) as elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 where ic.transaction_amt < 0
 group by 1
 order by 3 asc;

/*
 *  Next, negative contributions to committees from donors...
 */
select cm.cmte_nm as committee,
       td.donor,
       count(*) as neg_contribs,
       sum(ic.transaction_amt) as total_neg_amt,
       min(ic.transaction_amt) as min_neg_amt,
       round(avg(ic.transaction_amt), 2) as avg_neg_amt,
       array_agg(distinct ic.elect_cycle) as elect_cycles
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 where ic.transaction_amt < 0
 group by 1, 2
 order by 4 asc;

/*
 *  Finally, same as previous, by election cycle...
 */
select cm.cmte_nm as committee,
       td.donor,
       ic.elect_cycle,
       count(*) as neg_contribs,
       sum(ic.transaction_amt) as total_neg_amt,
       min(ic.transaction_amt) as min_neg_amt,
       round(avg(ic.transaction_amt), 2) as avg_neg_amt
  from top_314_donors td
  join indiv_contrib ic
       on  ic.indiv_id = td.indiv_id
  join cmte cm
       on cm.cmte_id = ic.cmte_id
 where ic.transaction_amt < 0
 group by 1, 2, 3
 order by 5 asc, 3 asc;

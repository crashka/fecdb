/*
 * ---------
 * Section 1
 * ---------
 *
 *  - I want to be able to search names while excluding zipcodes.
 *
 *  - I want to be able to print the output of that in an easy to read format split up by election cycle.
 */

/*
 * 1a. count number of individuals with specified name (as listed in the FEC data set)
 */
select count(*)
 * from indiv
 where name = 'SANDELL, SCOTT';

/*
 * 1b. count number of individuals whose name starts with a pattern
 */
select count(*)
  from indiv
 where name like 'SANDELL, %';

select count(*)
  from indiv
 where name like 'SANDELL, SCOTT%';

/*
 * 1c. or (the more techie way to do it, using a regular expression)...
 */
select count(*)
  from indiv
 where name ~ '^SANDELL, SCOTT';

/*
 * 1d. refine a previous result by adding a zip code clause
 */
select count(*)
  from indiv
 where name like 'SANDELL, %'
   and zip_code like '94025%';

/*
 * 1e. select name, city, state, zip_code, and election cycles for a specified name
 */
select name,
       city,
       state,
       zip_code,
       elect_cycles
  from indiv
 where name = 'SANDELL, SCOTT';

/*
 * 1f. filter the previous by specific election cycle
 */
select name,
       city,
       state,
       zip_code,
       elect_cycles
  from indiv
 where name = 'SANDELL, SCOTT'
   and 2016 = any (elect_cycles);

/*
 * 1g. same, but specify a set of election cycles
 */
select name,
       city,
       state,
       zip_code,
       elect_cycles
  from indiv
 where name = 'SANDELL, SCOTT'
   and elect_cycles && array[2016, 2018, 2020];


/*
 * ---------
 * Section 2
 * ---------
 *
 *  - I want to be able to see people who have donated to 314 and other things they have donated to predict
 *    who might be likely to donate to 314.
 */

/*
 * 2a. build working set for top 50 contributors to 314 (all time)
 */
create materialized view top_314_donors as
select i.id as indiv_id,
       i.name,
       i.city,
       i.state,
       i.zip_code,
       count(*) as num_contribs,
       sum(ct.transaction_amt) as total_amt,
       min(ct.transaction_dt) as earliest,
       max(ct.transaction_dt) as latest,
       array_agg(distinct ct.elect_cycle) as "314_elect_cycles"
  from indiv i
  join contrib_to_314 ct
       on ct.indiv_id = i.id
 group by 1, 2, 3, 4, 5
 order by 6 desc, 7 desc
 limit 50;

/*
 * 2b. query from working set of top contributors to 314
 */
select *
  from top_314_donors
 order by num_contribs desc, total_amt desc;

/*
 * 2c. query other contributions from top 314 contributors
 */
select td.indiv_id,
       td.name,
       td.city,
       td.state,
       td.zip_code,
       td.total_amt as total_314_amt,
       td."314_elect_cycles",
       array_agg(distinct cm.cmte_nm) as other_contrib_cmtes,
       sum(ic.transaction_amt) as total_other_amt
  from top_314_donors td
  join indiv_contrib ic
       on ic.indiv_id = td.indiv_id
  join cmte cm
       on cm.cmte_id = ic.cmte_id
       and cm.cmte_nm not like '314%'
 group by 1, 2, 3, 4, 5, 6, 7
 order by 9 desc;

/*
 * 2d. same as previous, but only look at other contributions in election cycles
 *     with 314 contributions
 */
select td.indiv_id,
       td.name,
       td.city,
       td.state,
       td.zip_code,
       td.total_amt as total_314_amt,
       td."314_elect_cycles",
       array_agg(distinct cm.cmte_nm) as other_contrib_cmtes,
       sum(ic.transaction_amt) as total_other_amt
  from top_314_donors td
  join indiv_contrib ic
       on ic.indiv_id = td.indiv_id
       and ic.elect_cycle = any (td."314_elect_cycles")
  join cmte cm
       on cm.cmte_id = ic.cmte_id
       and cm.cmte_nm not like '314%'
 group by 1, 2, 3, 4, 5, 6, 7
 order by 9 desc;

/*
 * 2e. drop the working set for 314 contributors if/when done with it (or can leave it, and later REFRESH
 *     it if the underlying base table data changes)
 */
drop materialized view top_314_donors;


/*
 * ---------
 * Section 3
 * ---------
 *
 *  - I am curious to see giving lives of people.
 *
 *  - I have noticed in a lot of my research thus far that people tend to get involved at some point and
 *    then after that point continuously donate a lot of money.
 *
 *  - I'm wondering if there is something that could link the upticks together.
 */


/*
 * ---------
 * Section 4
 * ---------
 *
 *  - I think similarly being able to graph sets of people or individuals' amount giving per cycle would be
 *    interesting.
 *
 *  - In the 2 year cycle when does a specific person tend to give (eg: when should we call them)?
 *
 *  - Are big donors or infrequent donors more likely to give in off years?
 */

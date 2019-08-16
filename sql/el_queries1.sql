/*
 *  Topic 1
 *
 *    - I want to be able to search names while excluding zipcodes.
 *
 *    - I want to be able to print the output of that in an easy to read
 *      format split up by election cycle.
 */

/*
 *  Let's see how many `indiv` records there are for a particular name
 */
select count(*)
  from indiv
 where name = 'SANDELL, SCOTT';

/*
 *  Okay, there aren't that many, let's see what they look like
 */
select name,
       city,
       state,
       zip_code,
       elect_cycles
  from indiv
 where name = 'SANDELL, SCOTT';

/*
 *  Okay, looks like the same person, with and without zip+4 representation, who many
 *  have moved, or perhaps specified a work address
 *
 *  Now, let's see if we can find other name representations for the same person
 */
select count(*)
  from indiv
 where name like 'SANDELL, SCOTT%';

/*
 *  Or, if you're a geek, you might prefer to do this using a regular expression
 */
select count(*)
  from indiv
 where name ~ '^SANDELL, SCOTT';

/*
 *  Let's take a look at these records
 */
select name,
       city,
       state,
       zip_code,
       elect_cycles
  from indiv
 where name like 'SANDELL, SCOTT%';

/*
 *  Looks like all the same person to me, so let's see how many distinct zip codes we're
 *  talking about (ignoring the +4)
 */
select distinct substr(zip_code, 1, 5) zip_prefix
  from indiv
 where name like 'SANDELL, SCOTT%';

/*
 *  Looks like just the two we saw before.  Now let's see if there are other contributors with
 *  the same last name in those zip codes
 */
select count(*)
  from indiv
 where name like 'SANDELL, %'
   and (zip_code like '94025%' or zip_code like '94028%');

/*
 *  Or, using regular expressions for the zip code predicate...
 */
select count(*)
  from indiv
 where name like 'SANDELL, %'
   and zip_code ~ '9402[58]';

/*
 *  Let's take a look at those names
 */
select distinct name
  from indiv
 where name like 'SANDELL, %'
   and zip_code ~ '9402[58]';

/*
 *  And at the names and zip code combinations
 */
select distinct name,
       substr(zip_code, 1, 5) zip_prefix
  from indiv
 where name like 'SANDELL, %'
   and zip_code ~ '9402[58]';

/*
 *  Okay, based on the shared zip code pattern, it's pretty clear this is all the
 *  same household here, so we can use this predicate on `indiv` to take a look at
 *  the contributions from this household by election cycle
 */
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
 group by 1
 order by 1;

/*
 *  There are some negative numbers in the 2008 and 2016 cycles, let's take a look
 *  at the individual contribution records
 */
select ic.elect_cycle,
       ic.name,
       ic.transaction_pgi,
       ic.transaction_tp,
       ic.entity_tp,
       ic.transaction_dt,
       ic.transaction_amt
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
   and ic.elect_cycle in (2008, 2016)
 order by ic.transaction_dt;

/*
 *  Looks like contributions for `transaction_pgi` = 'P' (Primary) were corrected
 *  to 'G' (General)--we'll let this slide for now, but should really understand
 *  if/how this might affect the overall accounting (not just for this household,
 *  but across all contribution records)
 *
 *  Ignoring that for the moment, let's now isolate presidential election cycles
 */
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
   and ic.elect_cycle % 4 = 0
 group by 1
 order by 1;

/*
 *  And mid-term election cycles
 */
select ic.elect_cycle,
       count(*) cycle_contribs,
       sum(ic.transaction_amt) cycle_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
   and ic.elect_cycle % 4 = 2
 group by 1
 order by 1;

/*
 *  Finally, let's look at totals for the presidential election cycles
 */
select count(*) total_contribs,
       sum(ic.transaction_amt) total_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
   and ic.elect_cycle % 4 = 0;

/*
 *  And totals for the mid-term election cycles
 */
select count(*) total_contribs,
       sum(ic.transaction_amt) total_amount,
       round(avg(ic.transaction_amt), 2) avg_amount,
       min(ic.transaction_amt) min_amount,
       max(ic.transaction_amt) max_amount
  from indiv i
  join indiv_contrib ic on ic.indiv_id = i.id
 where i.name like 'SANDELL, %'
   and i.zip_code ~ '9402[58]'
   and ic.elect_cycle % 4 = 2;

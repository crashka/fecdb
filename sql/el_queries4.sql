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

create materialized view base_def as
select *
  from base_indiv
 where name = 'SANDELL, SCOTT';

create materialized view base_contrib as
select ic.elect_cycle                                           as elect_cycle,
       ic.transaction_dt                                        as contrib_dt,
       sum(ic.transaction_amt)                                  as contrib_amt,
       count(*)                                                 as contribs,
       count(distinct i.name)                                   as donors,
       array_to_string(array_agg(distinct cmte.cmte_id), ', ')  as cmte_ids,
       array_to_string(array_agg(distinct cmte.cmte_nm), ' | ') as cmte_nms
  from base_def base
  join indiv i on i.base_indiv_id = base.id
  join indiv_contrib ic on ic.indiv_id = i.id
  left join cmte
       on cmte.cmte_id = ic.cmte_id
       and cmte.elect_cycle = ic.elect_cycle
 group by 1, 2;

create materialized view base_ec as
select ec.key                                   as key,
       ec.election_day                          as election_day,
       count(*)                                 as contrib_dates,
       sum(bc.contrib_amt)                      as total_amt,
       round(sum(bc.contrib_amt) / count(*), 2) as avg_amt,
       min(bc.contrib_dt)                       as earliest,
       max(bc.contrib_dt)                       as latest,
       min(bc.contrib_dt) - ec.election_day     as erly_days_rel,
       max(bc.contrib_dt) - ec.election_day     as late_days_rel
  from base_contrib bc
  join election_cycle ec on ec.key = bc.elect_cycle
 group by 1, 2;

select *
  from base_contrib
 order by 1, 2;

select *
  from base_ec
 order by 1;

/*
select bc.elect_cycle,
       bc.contrib_dt,
       bc.contrib_amt                   as total_amt,
       round(bc.contrib_amt / bec.total_amt * 100.0, 1)
                                        as cycle_pct,
       bc.contrib_dt - bec.election_day as days_rel
  from base_contrib bc
  join base_ec bec on bec.key = bc.elect_cycle
 order by 1, 2;
*/

select bc.elect_cycle,
       bc.contrib_dt,
       bc.contrib_amt                   as total_amt,
       round(bc.contrib_amt / bec.total_amt * 100.0, 1)
                                        as cycle_pct,
       cumul.total_amt                  as cumul_cycle_amt,
       round(cumul.total_amt / bec.total_amt * 100.0, 1)
                                        as cumul_cycle_pct,
       bc.contrib_dt - bec.election_day as days_rel
  from base_contrib bc
  join base_ec bec on bec.key = bc.elect_cycle
  left join lateral
       (select count(*)                as contribs,
               nullif(count(*) - 1, 0) as intervals,
               sum(bc2.contrib_amt)    as total_amt,
               max(bc2.contrib_dt) - min(bc2.contrib_dt)
                                       as elapsed_days
          from base_contrib bc2
         where bc2.elect_cycle = bc.elect_cycle
           and bc2.contrib_dt <= bc.contrib_dt
       ) as cumul on true
 order by 1, 2;

/*
 *  Cleanup context (drop in reverse order due to dependencies)
 */
drop materialized view base_ec;
drop materialized view base_contrib;
drop materialized view base_def;

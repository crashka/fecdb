create view contrib_to_314 as
select cm.cmte_nm,
       ic.*
  from cmte cm
  join indiv_contrib ic
       on ic.cmte_id = cm.cmte_id
 where cm.cmte_nm like '314%'

--
-- indiv_contrib records associated with any committee whose name is prefixed
-- by "314" (can be amended if there are other patterns representing the same
-- PAC; currently there are no others with "314" elsewhere in the name)
--
create or replace view contrib_to_314 as
select cm.cmte_nm,
       ic.*
  from cmte cm
  join indiv_contrib ic
       on ic.cmte_id = cm.cmte_id
 where cm.cmte_nm like '314%'

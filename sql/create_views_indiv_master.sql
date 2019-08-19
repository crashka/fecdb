--
--  base_indiv
--
create or replace view base_indiv as
select *
  from indiv
 where id = base_indiv_id;

--
--  hhh_indiv
--
create or replace view hhh_indiv as
select *
  from indiv
 where id = hhh_indiv_id;

--
--  bad_base_indiv_ids
--
create or replace view bad_base_indiv_ids as
select i.*
  from indiv i
  join indiv base_i
       on base_i.id = i.base_indiv_id
 where base_i.base_indiv_id != base_i.id;

--
--  bad_hhh_indiv_ids
--
create or replace view bad_hhh_indiv_ids as
select i.*
  from indiv i
  join indiv hhh_i
       on hhh_i.id = i.hhh_indiv_id
 where hhh_i.hhh_indiv_id != hhh_i.id;

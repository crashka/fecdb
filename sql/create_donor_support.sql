--
--  base_indiv (rename to `donor`???)
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

--
--  note that we could combine these two functions by parameterizing `fkcol`, but that
--  makes the invocation a little messier--needless to say, the code is the same except
--  for the column name declaration
--
--  TODO: redefine as stored procedures in PostgreSQL 11
--

--
--  Sample usage:
--
--      with indiv_set as (
--          select i.*
--            from indiv i
--           where i.name like 'SANDELL, SCOTT%'
--             and i.zip_code ~ '9402[58]'
--             and i.name !~ 'MRS\.'
--      )
--      select set_base_indiv('indiv', array_agg(id)) as base_indiv_id
--        from indiv_set;
--
CREATE OR REPLACE FUNCTION set_base_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS BIGINT AS $$
DECLARE
    fkcol  TEXT = 'base_indiv_id';
    sql    TEXT;
    min_id BIGINT;
    rows   INTEGER;
BEGIN
    sql = format('update %I
                     set %I = (select min(id) from unnest($1) id)
                   where id in (select unnest($1))
               returning %I', indiv_tbl, fkcol, fkcol);
    EXECUTE sql INTO min_id USING ids;

    GET DIAGNOSTICS rows = ROW_COUNT;
    --RAISE INFO 'Records updated: %', rows;
    RETURN min_id;
END;
$$ LANGUAGE plpgsql;

--
--  Sample usage:
--
--      with indiv_set as (
--          select i.*
--            from indiv i
--           where i.name like 'SANDELL, %'
--             and i.zip_code ~ '9402[58]'
--      )
--      select set_hhh_indiv('indiv', array_agg(id)) as hhh_indiv_id
--        from indiv_set;
--
CREATE OR REPLACE FUNCTION set_hhh_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS BIGINT AS $$
DECLARE
    fkcol TEXT = 'hhh_indiv_id';
    sql    TEXT;
    min_id BIGINT;
    rows   INTEGER;
BEGIN
    sql = format('update %I
                     set %I = (select min(id) from unnest($1) id)
                   where id in (select unnest($1))
               returning %I', indiv_tbl, fkcol, fkcol);
    EXECUTE sql INTO min_id USING ids;

    GET DIAGNOSTICS rows = ROW_COUNT;
    --RAISE INFO 'Records updated: %', rows;
    RETURN min_id;
END;
$$ LANGUAGE plpgsql;

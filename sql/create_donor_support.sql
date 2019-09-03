--
--  donor_indiv
--
create or replace view donor_indiv as
select *
  from indiv
 where id = donor_indiv_id;

--
--  hh_indiv
--
create or replace view hh_indiv as
select *
  from indiv
 where id = hh_indiv_id;

--
--  bad_donor_indiv_ids
--
create or replace view bad_donor_indiv_ids as
select i.*
  from indiv i
  join indiv donor
       on donor.id = i.donor_indiv_id
 where donor.donor_indiv_id != donor.id;

--
--  bad_hh_indiv_ids
--
create or replace view bad_hh_indiv_ids as
select i.*
  from indiv i
  join indiv hh
       on hh.id = i.hh_indiv_id
 where hh.hh_indiv_id != hh.id;

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
--      select set_donor_indiv('indiv', array_agg(id)) as donor_indiv_id
--        from indiv_set;
--
CREATE OR REPLACE FUNCTION set_donor_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS BIGINT AS $$
DECLARE
    fkcol  TEXT = 'donor_indiv_id';
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
--      select set_hh_indiv('indiv', array_agg(id)) as hh_indiv_id
--        from indiv_set;
--
CREATE OR REPLACE FUNCTION set_hh_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS BIGINT AS $$
DECLARE
    fkcol  TEXT = 'hh_indiv_id';
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

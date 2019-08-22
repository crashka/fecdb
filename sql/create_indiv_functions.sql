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
--            from hhh_indiv hhh
--            join indiv i on i.hhh_indiv_id = hhh.id
--                         and (i.name ~ 'SCOTT' and i.name !~ 'MRS\.')
--           where hhh.name = 'SANDELL, JENNIFER'
--      )
--      select set_base_indiv('indiv', array_agg(id)) from indiv_set;
--
CREATE OR REPLACE FUNCTION set_base_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS TEXT AS $$
DECLARE
    fkcol TEXT = 'base_indiv_id';
    sql   TEXT;
    res   INTEGER;
BEGIN
    sql = format('update %I'
                 '   set %I = (select min(id) from unnest($1) id)'
                 ' where id in (select unnest($1))', indiv_tbl, fkcol);
    EXECUTE sql USING ids;

    GET DIAGNOSTICS res = ROW_COUNT;
    RETURN res;
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
--      select set_hhh_indiv('indiv', array_agg(id)) from indiv_set;
--
CREATE OR REPLACE FUNCTION set_hhh_indiv(indiv_tbl TEXT, ids BIGINT[]) RETURNS TEXT AS $$
DECLARE
    fkcol TEXT = 'hhh_indiv_id';
    sql   TEXT;
    res   INTEGER;
BEGIN
    sql = format('update %I'
                 '   set %I = (select min(id) from unnest($1) id)'
                 ' where id in (select unnest($1))', indiv_tbl, fkcol);
    EXECUTE sql USING ids;

    GET DIAGNOSTICS res = ROW_COUNT;
    RETURN res;
END;
$$ LANGUAGE plpgsql;

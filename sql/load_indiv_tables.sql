-- size of hashkeys, in hex bytes (note: md5 is 32 bytes)
\set hashbytes 16
select 33 - :hashbytes as substr_off
\gset

-- we build `indiv2` first, just in case we want to be clever and bulid `indiv`
-- from it (as a reduced data set) rather than from indiv_contrib
insert into indiv2 (
       name,
       city,
       state,
       zip_code,
       employer,
       occupation,
       hashkey,
       elect_cycles
       )
select name,
       city,
       state,
       zip_code,
       employer,
       occupation,
       substr(md5(concat(name, '|',
                         city, '|',
                         state, '|',
                         zip_code, '|',
                         employer, '|',
                         occupation)), :substr_off),
       array_agg(distinct elect_cycle)
  from indiv_contrib
 group by 1, 2, 3, 4, 5, 6, 7;

\if 0
    -- we can build `indiv` the same as above...
    insert into indiv (
           name,
           city,
           state,
           zip_code,
           hashkey,
           elect_cycles
           )
    select name,
           city,
           state,
           zip_code,
           substr(md5(concat(name, '|',
                             city, '|',
                             state, '|',
                             zip_code)), :substr_off),
           array_agg(distinct elect_cycle)
      from indiv_contrib
     group by 1, 2, 3, 4, 5;
\else
    -- ...or here is us being clever (I think this works, and should be
    -- quite a bit faster)
    insert into indiv (
           name,
           city,
           state,
           zip_code,
           hashkey,
           elect_cycles
           )
    select name,
           city,
           state,
           zip_code,
           hashkey,
           array_agg(distinct elect_cycle)
      from (select name,
                   city,
                   state,
                   zip_code,
                   substr(md5(concat(name, '|',
                                     city, '|',
                                     state, '|',
                                     zip_code)), :substr_off) as hashkey,
                   unnest(elect_cycles) as elect_cycle
              from indiv2) as indiv2_unnested
     group by 1, 2, 3, 4, 5;
 \endif

--
-- full-table update will implicity copy the table, but don't need to do a
-- VACUUM since we will be dropping this table after recreating (for indiv
-- master foreign keys)
--
update indiv_contrib
   set indiv_hashkey  = substr(md5(concat(name, '|',
                                          city, '|',
                                          state, '|',
                                          zip_code)), :substr_off),
       indiv2_hashkey = substr(md5(concat(name, '|',
                                          city, '|',
                                          state, '|',
                                          zip_code, '|',
                                          employer, '|',
                                          occupation)), :substr_off);

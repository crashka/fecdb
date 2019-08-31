-- size of hashkeys, in hex bytes (note: md5 is 32 bytes)
\set hashbytes 16
select 33 - :hashbytes as substr_off
\gset

-- load all of the distinct PII in `indiv_contrib` into `indiv_info`; we also aggregate the
-- `elect_cycle` values so we can use them for building `indiv`, below
insert into indiv_info (
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
    -- we can build `indiv` as above (with `indiv_info`)...
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
    -- ...or here is us being clever in further collapsing the records in `indiv_info`...
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
              from indiv_info) as ii_unnest
     group by 1, 2, 3, 4, 5;
 \endif

--
-- this full-table update for setting hashkeys on `indiv_contrib` (to match those above) will
-- implicity copy the table, but we won't need to do a VACUUM since we will be dropping this
-- table after we recreate it (for setting foreign keys to `indiv_info` and `indiv` based on
-- the hashkeys)
--
update indiv_contrib
   set indiv_info_hashkey = substr(md5(concat(name, '|',
                                              city, '|',
                                              state, '|',
                                              zip_code, '|',
                                              employer, '|',
                                              occupation)), :substr_off),
       indiv_hashkey      = substr(md5(concat(name, '|',
                                              city, '|',
                                              state, '|',
                                              zip_code)), :substr_off);

-- size of hashkeys, in hex bytes (note: md5 is 32 bytes)
\set hashbytes 16
select 33 - :hashbytes as substr_off
\gset

insert into indiv2 (
       name,
       city,
       state,
       zip_code,
       employer,
       occupation,
       hashkey
       )
select distinct
       name,
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
                         occupation)), :substr_off)
  from indiv_contrib;

insert into indiv (
       name,
       city,
       state,
       zip_code,
       hashkey
       )
select distinct
       name,
       city,
       state,
       zip_code,
       substr(md5(concat(name, '|',
                         city, '|',
                         state, '|',
                         zip_code)), :substr_off)
  from indiv2;

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

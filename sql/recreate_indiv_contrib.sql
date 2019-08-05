-- just create a clean copy of indiv_contrib (rather than have
-- UPDATE do it implicitly)
CREATE TABLE indiv_contrib_new (LIKE indiv_contrib INCLUDING CONSTRAINTS);

-- check for possible hash collisions
select count(distinct i.hashkey) as collisions1
  from indiv i
 where exists
       (select *
          from indiv inner_i
         where inner_i.hashkey = i.hashkey
           and inner_i.id != i.id
       )
\gset

select count(distinct i2.hashkey) as collisions2
  from indiv2 i2
 where exists
       (select *
          from indiv2 inner_i2
         where inner_i2.hashkey = i2.hashkey
           and inner_i2.id != i2.id
       )
\gset

select (:collisions1 + :collisions2) = 0 as no_collisions
\gset

\if :no_collisions
    /*
    insert into indiv_contrib_new
    select ic.id,
           ic.cmte_id,
           ic.amndt_ind,
           ic.rpt_tp,
           ic.transaction_pgi,
           ic.image_num,
           ic.transaction_tp,
           ic.entity_tp,
           ic.name,
           ic.city,
           ic.state,
           ic.zip_code,
           ic.employer,
           ic.occupation,
           ic.transaction_dt,
           ic.transaction_amt,
           ic.other_id,
           ic.tran_id,
           ic.file_num,
           ic.memo_cd,
           ic.memo_text,
           ic.sub_id,
           ic.elect_cycle,
           ic.indiv_hashkey,
           ic.indiv2_hashkey,
           (select i.id
              from indiv i
             where i.hashkey = ic.indiv_hashkey) as indiv_id,
           (select i2.id
              from indiv2 i2
             where i2.hashkey = ic.indiv2_hashkey) as indiv2_id
      from indiv_contrib ic;
    */

    insert into indiv_contrib_new
    select ic.id,
           ic.cmte_id,
           ic.amndt_ind,
           ic.rpt_tp,
           ic.transaction_pgi,
           ic.image_num,
           ic.transaction_tp,
           ic.entity_tp,
           ic.name,
           ic.city,
           ic.state,
           ic.zip_code,
           ic.employer,
           ic.occupation,
           ic.transaction_dt,
           ic.transaction_amt,
           ic.other_id,
           ic.tran_id,
           ic.file_num,
           ic.memo_cd,
           ic.memo_text,
           ic.sub_id,
           ic.elect_cycle,
           ic.indiv_hashkey,
           ic.indiv2_hashkey,
           i.id as indiv_id,
           i2.id as indiv2_id
      from indiv_contrib ic
      left join indiv i on i.hashkey = ic.indiv_hashkey
      left join indiv2 i2 on i2.hashkey = ic.indiv2_hashkey;
\else
    -- fallback in case there is a hash collision
    /*
    insert into indiv_contrib_new
    select ic.id,
           ic.cmte_id,
           ic.amndt_ind,
           ic.rpt_tp,
           ic.transaction_pgi,
           ic.image_num,
           ic.transaction_tp,
           ic.entity_tp,
           ic.name,
           ic.city,
           ic.state,
           ic.zip_code,
           ic.employer,
           ic.occupation,
           ic.transaction_dt,
           ic.transaction_amt,
           ic.other_id,
           ic.tran_id,
           ic.file_num,
           ic.memo_cd,
           ic.memo_text,
           ic.sub_id,
           ic.elect_cycle,
           ic.indiv_hashkey,
           ic.indiv2_hashkey,
           (select i.id
              from indiv i
             where i.hashkey = ic.indiv_hashkey
               and coalesce(i.name, '')     = coalesce(ic.name, '')
               and coalesce(i.zip_code, '') = coalesce(ic.zip_code, '')
               and coalesce(i.city, '')     = coalesce(ic.city, '')
               and coalesce(i.state, '')    = coalesce(ic.state, '')) as indiv_id,
           (select i2.id
              from indiv2 i2
             where i2.hashkey = ic.indiv2_hashkey
               and coalesce(i2.name, '')       = coalesce(ic.name, '')
               and coalesce(i2.zip_code, '')   = coalesce(ic.zip_code, '')
               and coalesce(i2.city, '')       = coalesce(ic.city, '')
               and coalesce(i2.state, '')      = coalesce(ic.state, '')
               and coalesce(i2.employer, '')   = coalesce(ic.employer, '')
               and coalesce(i2.occupation, '') = coalesce(ic.occupation, '')) as indiv2_id
      from indiv_contrib ic;
    */

    insert into indiv_contrib_new
    select ic.id,
           ic.cmte_id,
           ic.amndt_ind,
           ic.rpt_tp,
           ic.transaction_pgi,
           ic.image_num,
           ic.transaction_tp,
           ic.entity_tp,
           ic.name,
           ic.city,
           ic.state,
           ic.zip_code,
           ic.employer,
           ic.occupation,
           ic.transaction_dt,
           ic.transaction_amt,
           ic.other_id,
           ic.tran_id,
           ic.file_num,
           ic.memo_cd,
           ic.memo_text,
           ic.sub_id,
           ic.elect_cycle,
           ic.indiv_hashkey,
           ic.indiv2_hashkey,
           i.id as indiv_id,
           i2.id as indiv2_id
      from indiv_contrib ic
      left join indiv i   on i.hashkey = ic.indiv_hashkey
                         and coalesce(i.name, '')     = coalesce(ic.name, '')
                         and coalesce(i.zip_code, '') = coalesce(ic.zip_code, '')
                         and coalesce(i.city, '')     = coalesce(ic.city, '')
                         and coalesce(i.state, '')    = coalesce(ic.state, '')
      left join indiv2 i2 on i2.hashkey = ic.indiv2_hashkey
                         and coalesce(i2.name, '')       = coalesce(ic.name, '')
                         and coalesce(i2.zip_code, '')   = coalesce(ic.zip_code, '')
                         and coalesce(i2.city, '')       = coalesce(ic.city, '')
                         and coalesce(i2.state, '')      = coalesce(ic.state, '')
                         and coalesce(i2.employer, '')   = coalesce(ic.employer, '')
                         and coalesce(i2.occupation, '') = coalesce(ic.occupation, '');
\endif

-- integrity check
select count(*) as null_ids1
  from indiv_contrib_new
 where indiv_id is null
\gset

select count(*) as null_ids2
  from indiv_contrib_new
 where indiv2_id is null
\gset

select (:null_ids1 + :null_ids2) = 0 as success
\gset

\if :success
    DROP TABLE indiv_contrib;
    ALTER TABLE indiv_contrib_new RENAME TO indiv_contrib;

    ALTER TABLE indiv_contrib ADD PRIMARY KEY (id);
    ALTER TABLE indiv_contrib ALTER id ADD GENERATED BY DEFAULT AS IDENTITY;
    ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv_id) REFERENCES indiv (id);
    ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv2_id) REFERENCES indiv2 (id);
\else
    \echo indiv_ids not set (:null_ids1 :null_ids2), exiting...
    \quit
\endif

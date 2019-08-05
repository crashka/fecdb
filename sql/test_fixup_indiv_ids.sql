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
    select count(*), count(indiv_id), count(indiv2_id)
      from (select ic.id,
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
              from indiv_contrib ic
           ) as indiv_contrib_new;

    select count(*), count(indiv_id), count(indiv2_id)
      from (select ic.id,
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
              left join indiv2 i2 on i2.hashkey = ic.indiv2_hashkey
           ) as indiv_contrib_new;
\else
    select count(*), count(indiv_id), count(indiv2_id)
      from (select ic.id,
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
              from indiv_contrib ic
           ) as indiv_contrib_new;

    select count(*), count(indiv_id), count(indiv2_id)
      from (select ic.id,
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
                                 and coalesce(i2.occupation, '') = coalesce(ic.occupation, '')
           ) as indiv_contrib_new;
\endif

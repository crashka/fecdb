-- use hash join for `indiv_info_id` and `indiv_id` fixups; alternative is nested
-- loop, which is slower but predictably linear time
\set use_hash_join true

-- check for possible hash collisions
select count(distinct ii.hashkey) as collisions1
  from indiv_info ii
 where exists
       (select *
          from indiv_info inner_ii
         where inner_ii.hashkey = ii.hashkey
           and inner_ii.id != ii.id
       )
\gset

select count(distinct i.hashkey) as collisions2
  from indiv i
 where exists
       (select *
          from indiv inner_i
         where inner_i.hashkey = i.hashkey
           and inner_i.id != i.id
       )
\gset

select (:collisions1 + :collisions2) = 0 as no_collisions
\gset

-- in all possible cases, we create a clean copy of `indiv_contrib` with the
-- `indiv_info` and `indiv` foreign keys added (rather than have UPDATE do it
-- implicitly); this also gives us a chance to make the table leaner (i.e. get
-- rid of the denorms and hashkeys)
\if :no_collisions
    \if :use_hash_join
        create table indiv_contrib_new as
        select ic.id,
               ic.cmte_id,
               ic.amndt_ind,
               ic.rpt_tp,
               ic.transaction_pgi,
               ic.image_num,
               ic.transaction_tp,
               ic.entity_tp,
               ic.transaction_dt,
               ic.transaction_amt,
               ic.other_id,
               ic.tran_id,
               ic.file_num,
               ic.memo_cd,
               ic.memo_text,
               ic.sub_id,
               ic.elect_cycle,
               ii.id as indiv_info_id,
               i.id as indiv_id
          from indiv_contrib ic
          left join indiv_info ii on ii.hashkey = ic.indiv_info_hashkey
          left join indiv i on i.hashkey = ic.indiv_hashkey;
    \else
        -- nested loop alternative
        create table indiv_contrib_new as
        select ic.id,
               ic.cmte_id,
               ic.amndt_ind,
               ic.rpt_tp,
               ic.transaction_pgi,
               ic.image_num,
               ic.transaction_tp,
               ic.entity_tp,
               ic.transaction_dt,
               ic.transaction_amt,
               ic.other_id,
               ic.tran_id,
               ic.file_num,
               ic.memo_cd,
               ic.memo_text,
               ic.sub_id,
               ic.elect_cycle,
               (select ii.id
                  from indiv_info ii
                 where ii.hashkey = ic.indiv_info_hashkey) as indiv_info_id,
               (select i.id
                  from indiv i
                 where i.hashkey = ic.indiv_hashkey) as indiv_id
          from indiv_contrib ic;
    \endif
\else
    -- fallback in case there is a hash collision (need to add individual data
    -- columns to join condition)
    \if :use_hash_join
        create table indiv_contrib_new as
        select ic.id,
               ic.cmte_id,
               ic.amndt_ind,
               ic.rpt_tp,
               ic.transaction_pgi,
               ic.image_num,
               ic.transaction_tp,
               ic.entity_tp,
               ic.transaction_dt,
               ic.transaction_amt,
               ic.other_id,
               ic.tran_id,
               ic.file_num,
               ic.memo_cd,
               ic.memo_text,
               ic.sub_id,
               ic.elect_cycle,
               ii.id as indiv_info_id,
               i.id as indiv_id
          from indiv_contrib ic
          left join indiv_info ii  on ii.hashkey                  = ic.indiv_info_hashkey
                                  and coalesce(ii.name, '')       = coalesce(ic.name, '')
                                  and coalesce(ii.zip_code, '')   = coalesce(ic.zip_code, '')
                                  and coalesce(ii.city, '')       = coalesce(ic.city, '')
                                  and coalesce(ii.state, '')      = coalesce(ic.state, '')
                                  and coalesce(ii.employer, '')   = coalesce(ic.employer, '')
                                  and coalesce(ii.occupation, '') = coalesce(ic.occupation, '')
          left join indiv i        on i.hashkey                   = ic.indiv_hashkey
                                  and coalesce(i.name, '')        = coalesce(ic.name, '')
                                  and coalesce(i.zip_code, '')    = coalesce(ic.zip_code, '')
                                  and coalesce(i.city, '')        = coalesce(ic.city, '')
                                  and coalesce(i.state, '')       = coalesce(ic.state, '');
    \else
        -- nested loop alternative
        create table indiv_contrib_new as
        select ic.id,
               ic.cmte_id,
               ic.amndt_ind,
               ic.rpt_tp,
               ic.transaction_pgi,
               ic.image_num,
               ic.transaction_tp,
               ic.entity_tp,
               ic.transaction_dt,
               ic.transaction_amt,
               ic.other_id,
               ic.tran_id,
               ic.file_num,
               ic.memo_cd,
               ic.memo_text,
               ic.sub_id,
               ic.elect_cycle,
               (select ii.id
                  from indiv_info ii
                 where ii.hashkey                  = ic.indiv_info_hashkey
                   and coalesce(ii.name, '')       = coalesce(ic.name, '')
                   and coalesce(ii.zip_code, '')   = coalesce(ic.zip_code, '')
                   and coalesce(ii.city, '')       = coalesce(ic.city, '')
                   and coalesce(ii.state, '')      = coalesce(ic.state, '')
                   and coalesce(ii.employer, '')   = coalesce(ic.employer, '')
                   and coalesce(ii.occupation, '') = coalesce(ic.occupation, '')) as indiv_info_id,
               (select i.id
                  from indiv i
                 where i.hashkey                   = ic.indiv_hashkey
                   and coalesce(i.name, '')        = coalesce(ic.name, '')
                   and coalesce(i.zip_code, '')    = coalesce(ic.zip_code, '')
                   and coalesce(i.city, '')        = coalesce(ic.city, '')
                   and coalesce(i.state, '')       = coalesce(ic.state, '')) as indiv_id
          from indiv_contrib ic;
    \endif
\endif

-- integrity check
select count(*) as null_ids1
  from indiv_contrib_new
 where indiv_info_id is null
\gset

select count(*) as null_ids2
  from indiv_contrib_new
 where indiv_id is null
\gset

select (:null_ids1 + :null_ids2) = 0 as success
\gset

\if :success
    DROP TABLE indiv_contrib;
    ALTER TABLE indiv_contrib_new RENAME TO indiv_contrib;

    ALTER TABLE indiv_contrib ADD PRIMARY KEY (id);
    ALTER TABLE indiv_contrib ALTER id ADD GENERATED BY DEFAULT AS IDENTITY;
    ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv_info_id) REFERENCES indiv_info (id) ON DELETE SET NULL;
    ALTER TABLE indiv_contrib ADD FOREIGN KEY (indiv_id)      REFERENCES indiv (id)      ON DELETE SET NULL;

    DROP INDEX indiv_info_hashkey;
    DROP INDEX indiv_hashkey;

    CREATE VIEW indiv_contrib_fec AS
    SELECT ic.id,
           ic.cmte_id,
           ic.amndt_ind,
           ic.rpt_tp,
           ic.transaction_pgi,
           ic.image_num,
           ic.transaction_tp,
           ic.entity_tp,
           ii.name,
           ii.city,
           ii.state,
           ii.zip_code,
           ii.employer,
           ii.occupation,
           ic.transaction_dt,
           ic.transaction_amt,
           ic.other_id,
           ic.tran_id,
           ic.file_num,
           ic.memo_cd,
           ic.memo_text,
           ic.sub_id,
           ic.elect_cycle
      FROM indiv_contrib ic
      JOIN indiv_info ii ON ii.id = ic.indiv_info_id;
\else
    \echo indiv_ids not set (:null_ids1 :null_ids2), exiting...
    \quit
\endif

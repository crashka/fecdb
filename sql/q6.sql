--
-- summary of committee contributions to committees, by target
--
select cmm.cmte_id as tgt_cmte_id,
       cm.cmte_nm as tgt_cmte_nm,
       cm.cmte_pty_affiliation as tgt_cmte_pty_affiliation,
       sum(cmm.transaction_amt) as total_amt,
       count(cmm.transaction_amt) as total_count
  from cmte_misc cmm
  join cmte cm on cm.cmte_id = cmm.cmte_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

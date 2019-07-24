--
-- summary of committee contributions to committees, by source
--
select cmm.other_id as src_cmte_id,
       cm.cmte_nm as src_cmte_nm,
       cm.cmte_pty_affiliation as src_cmte_pty_affiliation,
       sum(cmm.transaction_amt) as total_amt,
       count(cmm.transaction_amt) as total_count
  from cmte_misc cmm
  join cmte cm on cm.cmte_id = cmm.other_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

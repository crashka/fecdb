--
-- summary of individual contributions to candidates (through candidate-committee link)
--
select ccl.cand_id,
       cn.cand_name,
       cn.cand_pty_affiliation,
       sum(ic.transaction_amt) as total_amt,
       count(ic.transaction_amt) as total_count
  from indiv_contrib ic
  join cand_cmte ccl on ccl.cmte_id = ic.cmte_id
  join cand cn on cn.cand_id = ccl.cand_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

--
-- summary of individual contributions to candidates (through committee)
--
select cm.cand_id,
       cn.cand_name,
       cn.cand_pty_affiliation,
       sum(ic.transaction_amt) as total_amt,
       count(ic.transaction_amt) as total_count
  from indiv_contrib ic
  join cmte cm on cm.cmte_id = ic.cmte_id
  join cand cn on cn.cand_id = cm.cand_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

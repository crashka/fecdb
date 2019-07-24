--
-- summary of committee contributions to candidates, by candidate (target)
--
select cc.cand_id,
       cn.cand_name,
       cn.cand_pty_affiliation,
       sum(cc.transaction_amt) as total_amt,
       count(cc.transaction_amt) as total_count
  from cmte_contrib cc
  join cand cn on cn.cand_id = cc.cand_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

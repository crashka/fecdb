--
-- summary of commmittee contributions to candidates, by committee (source)
--
select cc.cmte_id as src_cmte_id,
       cc.name as src_name,
       cc.entity_tp as src_entity_tp,
       cm.cmte_nm,
       cm.cmte_pty_affiliation,
       sum(cc.transaction_amt) as total_amt,
       count(cc.transaction_amt) as total_count
  from cmte_contrib cc
  join cmte cm on cm.cmte_id = cc.cmte_id
 group by 1, 2, 3, 4, 5
 order by 6 desc
 limit 20

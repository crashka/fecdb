--
-- summary of individual contributions to committees
--
select ic.cmte_id,
       cm.cmte_nm,
       cm.cmte_pty_affiliation,
       sum(ic.transaction_amt) as total_amt,
       count(ic.transaction_amt) as total_count
  from indiv_contrib ic
  join cmte cm on cm.cmte_id = ic.cmte_id
 group by 1, 2, 3
 order by 4 desc
 limit 20

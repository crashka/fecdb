select c.cand_id,
       c.cand_name,
       c.cand_pty_affiliation,
       c.cand_election_yr,
       (select count(*)
         from cmte cm
        where cm.cand_id = c.cand_id) as committees,
       (select count(*)
         from cand_cmte cc
         join cmte cm on cm.cmte_id = cc.cmte_id
        where cc.cand_id = c.cand_id) as committee_links
  from cand c
 order by 5 desc
 limit 50

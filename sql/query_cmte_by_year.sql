with cmte_sum as (
     select c.cmte_nm, extract(year from i.transaction_dt) transaction_yr,
            sum(i.transaction_amt) transaction_sum, count(i.transaction_amt) transaction_cnt
       from cmte c
       join indiv i on i.cmte_id = c.cmte_id
   group by 1, 2
   )
select cs.cmte_nm committee, sum(cs.transaction_sum) total, sum(cs.transaction_cnt) count,
       sum(case cs.transaction_yr when 2019 then cs.transaction_sum else 0 end) "2019_amt",
       sum(case cs.transaction_yr when 2018 then cs.transaction_sum else 0 end) "2018_amt",
       sum(case cs.transaction_yr when 2017 then cs.transaction_sum else 0 end) "2017_amt",
       sum(case cs.transaction_yr when 2016 then cs.transaction_sum else 0 end) "2016_amt",
       sum(case cs.transaction_yr when 2015 then cs.transaction_sum else 0 end) "2015_amt",
       sum(case when cs.transaction_yr between 2015 and 2019 then 0 else cs.transaction_sum end) other_amt
  from cmte_sum cs
 group by 1
 order by 2 desc
 limit 100

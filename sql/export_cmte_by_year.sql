copy (
with cmte_sum as (
     select c.cmte_nm, extract(year from i.transaction_dt) txn_yr,
            sum(i.transaction_amt) txn_sum, count(i.transaction_amt) txn_cnt
       from cmte c
       join indiv i on i.cmte_id = c.cmte_id
   group by 1, 2
   )
select cs.cmte_nm "Committee Name", sum(cs.txn_sum) "Total Amount", sum(cs.txn_cnt) "Transactions",
       sum(case cs.txn_yr when 2019 then cs.txn_sum else 0 end) "2019 Amount",
       sum(case cs.txn_yr when 2018 then cs.txn_sum else 0 end) "2018 Amount",
       sum(case cs.txn_yr when 2017 then cs.txn_sum else 0 end) "2017 Amount",
       sum(case cs.txn_yr when 2016 then cs.txn_sum else 0 end) "2016 Amount",
       sum(case cs.txn_yr when 2015 then cs.txn_sum else 0 end) "2015 Amount",
       sum(case when cs.txn_yr between 2015 and 2019 then 0 else cs.txn_sum end) "Other Amount"
  from cmte_sum cs
 group by 1
 order by 2 desc
)
to '/tmp/cmte_by_year.csv'
with (format csv, header true)

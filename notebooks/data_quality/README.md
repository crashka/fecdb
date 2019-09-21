# Data Quality #

Note that "data quality" is somewhat of a misnomer, the purpose here is to explore not only the
flaws (e.g. inconsistencies, typos, etc.) in the data, but also the conventions and quirks that are
not obvious.  If all of these factors are not understood, then many query results may lead to
inaccurate, misleading, or plainly errant interpretations and conclusions.

## Topics/Issues by Area ##

### Individuals/Donors ###

* Consistency of Individual identifying information
    * Name
    * Address information (city, state, zip code)
    * Work information (organization, role)
    * "Entity type"

### Individual/Donor Contributions ###

* Negative contribution amounts
* Consistency of transaction types, and consideration of type in querying/accounting
* Anomalous transaction dates
* Use/meaning of `other_id`

### Committees ###

* Consistency of Committee identifying information
    * Replication within, or across, election cycles
* Association with Candidates
    * Use of `cand_id` key vs. join through `cand_cmte` intersect table

### Committee Contributions/Transactions ###

* Understand meaning of (and differences between) "contributions", "independent expenditures", and
  "miscellaneous transactions"

### Candidates ###

* Consistency of Campaign identifying information
    * Replication within, or across, election cycles
    * Consideration of `cand_status` in coelescing records, especially "P" value
* Association with Candidates
    * Use of `cand_pcc` key vs. join through `cand_cmte` intersect table, also as compared with
      `cmte.cand_id` association

## Generic Topics/Issues ##

* Fidelity of election cycle file boundaries (captured in the database as `elect_cycle` column for
  all base tables)
* Understand variation/changes in "quality" over time
    * Variations/changes within specific election cycles
    * Variations/changes *across* election cycles
        * Is data quality getting better over time?

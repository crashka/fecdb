# Jupyter Notebooks #

## Define Context ##

The following notebooks are included in the `define_context` directory as examples for
how to create contexts for querying, based on common use cases:

* `dc1_ctx_indiv_single_person`
* `dc2_ctx_indiv_multi_person`
* `dc3_ctx_donor_multi_person`
* `dc4_ctx_household_by_last_name_zip`
* `dc5_ctx_iseg_household`
* `dc6_ctx_dseg_total_amt_tiered_sample`
* `dc7_ctx_dseg_top_314_donors`

Note that each notebook also creates the dependent ("downstream") contexts that are
implicitly determined by the principal context defined in each case.  See the individual
(lower case "i") notebooks for explanations and discussion.

## Query Context ##

Once a principal context and its dependent contexts have been defined, the notebooks
in this directory can be used as examples for forming queries on the various contexts
that may be set:

* `qc1_ctx_contrib`
* `qc2_ctx_contrib_donor`
* `qc3_ctx_indiv`
* `qc4_ctx_donor`
* `qc5_ctx_household`
* `qc6_ctx_iseg`
* `qc7_ctx_dseg`

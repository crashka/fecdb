# Jupyter Notebooks #

## Define Context ##

The following notebooks are included in the `define_context` directory as examples for
how to create contexts for querying, based on common use cases:

* `dc1_ctx_indiv_single_person`
* `dc2_ctx_indiv_multi_person`
* `dc3_ctx_household_by_last_name_zip`
* `dc4_ctx_iseg_household`
* `dc5_ctx_donor_multi_person`
* `dc6_ctx_dseg_top_314_donors`
* `dc7_ctx_dseg_total_amt_tiered_sample`

See the individual (lower case "i") notebooks for details and discussion.

Note that each notebook also creates the dependent ("downstream") contexts that are
implicitly determined by the principal context defined in each case.

| Principal Context View | Dependent Context Views |
| --- | --- |
| `ctx_indiv_contrib` | *none* |
| `ctx_indiv` | `ctx_indiv_contrib` |
| `ctx_household` | `ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_iseg` | `ctx_iseg_memb`\*<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_donor_contrib` | *none* |
| `ctx_donor` | `ctx_donor_contrib`<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_dseg` | `ctx_dseg_memb`\*<br/>`ctx_donor`<br/>`ctx_donor_contrib`<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |


\* Segment membership context views (`ctx_iseg_memb` and `ctx_dseg_memb`) are not
typically used (though available nonetheless) for querying, thus sample notebooks are
not provided for them below.

## Query Context ##

Once a principal context and its dependent contexts have been defined, the notebooks
in the `query_context` directory can be used as examples for forming queries on the
various contexts that may be set:

* `qc1_ctx_indiv_contrib`
* `qc2_ctx_indiv`
* `qc3_ctx_iseg`
* `qc4_ctx_household`
* `qc5_ctx_donor_contrib`
* `qc6_ctx_donor`
* `qc7_ctx_dseg`

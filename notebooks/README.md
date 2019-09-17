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

See the individual (lower case "i") notebooks for more details and discussion.

Each notebook here also creates the dependent ("downstream") contexts that are
implicitly determined by the principal context defined in each case.

| Principal Context View | Dependent Context Views |
| --- | --- |
| `ctx_indiv_contrib` | *none* |
| `ctx_indiv` | `ctx_indiv_contrib` |
| `ctx_household` | `ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_iseg`\* | `ctx_iseg_memb`\*<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_donor_contrib` | *none* |
| `ctx_donor` | `ctx_donor_contrib`<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |
| `ctx_dseg`\* | `ctx_dseg_memb`\*<br/>`ctx_donor`<br/>`ctx_donor_contrib`<br/>`ctx_indiv`<br/>`ctx_indiv_contrib` |


\* Context views for Segment and Segment Membership (`ctx_iseg`, `ctx_iseg_memb`, `ctx_dseg`, and
`ctx_dseg_memb`) are not typically used for querying, thus sample notebooks are not provided for
them in `query_context` (see below).  They are, however, part of the overall pattern, and very
useful for top-down specification of contexts, which are then embodied in their dependent views.

Note that the context views in any of these notebooks (or if specified through other means) can also
be created as [materialized views](https://www.postgresql.org/docs/10/rules-materializedviews.html),
especially if they are somewhat expensive to query (large or complex query logic or result sets) and
will be used multiple times for investigation or reporting.  Dependent context views do not have to
be recreated when the principal context view is changed, though they will need to be
"[refreshed](https://www.postgresql.org/docs/10/sql-refreshmaterializedview.html)" if defined as a
materialized view.

## Query Context ##

Once a principal context and its dependent contexts have been defined, the notebooks
in the `query_context` directory can be used as examples for forming queries on the
various contexts that may be set:

* `qc1_ctx_indiv_contrib`
* `qc2_ctx_indiv`
* `qc3_ctx_household`
* `qc4_ctx_donor_contrib`
* `qc5_ctx_donor`

## Issues ##

* Because the context views have fixed names, only one logical context can be specified
  at any given time.  Thus multiple users cannot use this pattern concurrently without
  romping on each other.

    * This can be solved by having each user create context views within their private
      schema, which is included in `search_path`, by default, ahead of `public` (where
      the common tables, views, etc. reside).

* It would be nice to have to standard way of specifying metadata for the current context,
  including a name, what it represents, and how (or where) it was defined.  The common
  usage flow may be to define (or redefine) a context and query against it immediately,
  but in cases where there is a time gap between the two operations, the knowledge and
  understanding of the context may be lost.

* It would also be nice to be able to define several different named contexts (with other
  identifying metadata, as discussed for above) and be able to swtich between them when
  querying&mdash;or possibly even plot them against each other.

    * As above, separate contexts can be implemented as sets of views within disparate
      schemas for a user (additional support would be needed to query or plot from views
      across schemas).

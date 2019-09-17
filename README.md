# fecdb &ndash; database scripts for FEC bulk data #

## Project ##

### Overview ###

This project contains simple scripts for the following:

* Downloading bulk data files from the FEC (Federal Election Commission) website
* Creating RDBMS (PostgreSQL) tables for the FEC data sets
* Loading the FEC bulk data into the database
* Indexes and views for supporting various queries against the database
* Sample SQL queries and Jupyter notebooks for exploring specific scenarios within the data

### FEC Data Sets ###

The following data sets from the [FEC website][1] are currently supported:

| Name (with link) | FEC file name | PostgreSQL table |
| --- | --- | --- |
| [Candidate Master][2] | cn | `cand` |
| [Candidate Financials][3] | weball | `cand_fins` |
| [Committee Master][4] | cm | `cmte` |
| [Committee Financials][5] | webk | `cmte_fins` |
| [Committee Contributions][6] | pas2 | `cmte_contrib` |
| [Committee Miscellaneous Transactions][7] | oth | `cmte_misc` |
| [Candidate-Committee Link][8] | ccl | `cand_cmte` |
| [Individual Contributions][9] | indiv | `indiv_contrib` |

In addition, the following tables have been created for reference data (code lookups), in support
of the bulk data

| Name (with link) | PostgreSQL table |
| --- | --- |
| [Transaction Type][10] | `transaction_type` |
| [Committee Type][11] | `cmte_type` |
| [Party][12] | `party` |

### Database Design Principles ###

* Preserve original data fields and values as much as possible (e.g. for traceability)&mdash;exceptions:
    * Normalize date fields so they will import as native PostgreSQL `DATE` types
    * Fix-up of spaces and commas in `name` field (`indiv` data set only, for now)
    * Convert `name` field (for `indiv`) to upper case (some earlier data sets used mixed case, inconsistently)
* Extensions to the original schema:
    * Primary key (autogenerated `BIGINT`)
    * Election cycle field (`elect_cycle`), based on source data set year (e.g. 2000, 2002, etc.)
    * Election cycle table (`election_cycle`), containing reference information for each cycle (e.g. election day date)
    * Derived (inferred) "Individual Master" tables (see below)
    * "Segments" for Individuals/Donors (see below)
* The objective is to leverage the database in doing some of the heavy lifting for big data
  processing, but not have it try and do too much stuff it is not good at.  We will provide some
  simple examples of how to extract joined subsets and rollups for processing and visualization in
  Jupyter notebooks (and Pandas), but similar integrations with other tools that are well-suited
  and/or more familiar for analysis and reporting (e.g. Excel, R, etc.) are also possible.

### Individual Master Data ###

A major challenge with the individual contribution data is that there are no "master" Individual
records (e.g. the way there are with candidates and committees), so it is difficult to determine
with integrity which contributions were made by the same real-world person, or different people with
the same (or similar) names.  To attempt to rectify, we extract unique combinations of `name` (a
single text field in the FEC data)&mdash;standardized within reason&mdash;and other personally
identifying information (e.g. address, employment) into separate tables to serve as the basis of
**Individual Master** data.  From there, we can do further processing and correlation to identify
additional possible duplication across prospective master records.  We will support the ability to
run various matching algorithms (including manual fixups) in an attempt to achieve more accurate
(truthful?) query results.

To augment the capabilities of the Individual master data, we introduce the notion of **Segments**,
which are collections of Individuals (based on demographics, contribution history, etc.)&msash;with
or without underlying matching associations to real-world people (called "Donors" below)&msash;that
we may wish to consider jointly in analysis and the search for insights.

Here are the tables introduced in support of the (inferred) individual master data:

| Entity name | PostgreSQL table | Description |
| --- | --- | --- |
| Individual Info | `indiv_info` | Extraction/normalization of PII (name, city, state, zip_code, employer, and occupation values) from `indiv_contrib` |
| Individual | `indiv` | Further distillation of `indiv_info`, factoring out obviously noisy data |
| Individual Segment | `indiv_seg` (and `indiv_seg_memb`) | Grouping of Individual records representing demographic/behavioral cohorts |
| Donor | `donor_indiv` (view) | Connection between `indiv` records deemed/propounded to represent the same real-world person |
| Donor Segment | `donor_seg` (and `donor_seg_memb`) | Grouping of Donors records&mdash;same as Individual Segment, but with resolution to identifiable people |

### Status ###

This is work in process.

### To Do ###

* More/better indexes and views to support common/interesting patterns of investigation with the data
* Metrics and reports for quality/integrity of the data
    * Understand and report on variability across time (i.e. election cycles)
* More sophisticated matching algorithm for identifying Donors (from Individuals)
    * Ability to define and test various matching algorithms against each other

## Requirements ##

The current package is depenent on the following:

* PostgreSQL 10
* A unix-like environment (e.g. bash, gawk, sed, etc.)
    * Not yet tested on cygwin, but that is planned
* Python 3
    * Python is currently only used as a scripting tool, thus only standard libraries are used, and there
      is no need to create a virtual environment for this project.  Later, if more complex Python-based
      functionality is introduced, the external library requirements will be listed.

These should be installed in your environment before proceeding with the set up instructions below.

## Setting Things Up ##

*The following example steps show the process for dowloading and loading the data from 2000 through
2020 election cycles (resulting in a ~30GB database).  All of the scripts support working with data
from multiple elections years (named after the even years)&mdash;fuller documentation to come.*

### Download data sets ###

    $ cd data
    $ for elect_cycle in 2020 2018 2016 2014 2012 2010 2008 2006 2004 2002 2000 ; do
    >   ../scripts/wget_fec_data.sh $elect_cycle
    > done
    $ ls *.zip
    $ cd ..

*Note that the `wget_fec_data.sh` script is pretty basic, so only downloads into the current working directory*

### Create database and tables ###

    $ createdb fecdb
    $ psql -ef sql/create_tables.sql fecdb

*Note that any of the command line database operations in this step (or following steps) can also be done equivalently
through a GUI (e.g. pgadmin).*

### Load data from files ###

    $ python3 scripts/load_fec_data.py all 2020,2018,2016,2014,2012,2010,2008,2006,2004,2002,2000 fecdb
    $ psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fecdb
    $ psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fecdb
    $ psql -c "\\copy party from 'data/party.txt'" fecdb
    $ psql -c "\\copy election_cycle from 'data/election_cycle.txt'" fecdb

### Load/normalize "Individual master" tables ###

    $ psql -ef sql/load_indiv_tables.sql fecdb
    $ psql -ef sql/create_indexes0.sql fecdb
    $ psql -ef sql/analyze_tables0.sql fecdb
    $ psql -ef sql/recreate_indiv_contrib.sql fecdb

### Create supporting indexes, views, and functions ###

    $ psql -ef sql/create_indexes.sql fecdb
    $ psql -ef sql/analyze_tables.sql fecdb
    $ psql -ef sql/create_donor_support.sql fecdb
    $ psql -ef sql/create_donor_seg_support.sql fecdb
    $ psql -ef sql/create_indiv_seg_support.sql fecdb
    $ psql -ef sql/create_name_parsing_support.sql fecdb

## Issues ##

* Need to categorize the various transaction types into categories for accurate insights (see
  `data/transaction_type.xlsx` for a worksheet that might be helpful)
* Need to understand exact role of `cmte_id` and `other_id` for various transaction type
  categories in **Committee Contributions** and **Committee Miscellaneous Transactions**
* Probably need to rename **Committee Contributions** and **Committee Miscellaneous Transactions**
  (both entity and table names) once the various transactions within them are better understood

## License ##

This project is licensed under the terms of the MIT License.

[1]:  https://www.fec.gov/data/browse-data/?tab=bulk-data
[2]:  https://www.fec.gov/campaign-finance-data/candidate-master-file-description/
[3]:  https://www.fec.gov/campaign-finance-data/all-candidates-file-description/
[4]:  https://www.fec.gov/campaign-finance-data/committee-master-file-description/
[5]:  https://www.fec.gov/campaign-finance-data/pac-and-party-summary-file-description/
[6]:  https://www.fec.gov/campaign-finance-data/contributions-committees-candidates-file-description/
[7]:  https://www.fec.gov/campaign-finance-data/any-transaction-one-committee-another-file-description/
[8]:  https://www.fec.gov/campaign-finance-data/candidate-committee-linkage-file-description/
[9]:  https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/
[10]: https://www.fec.gov/campaign-finance-data/transaction-type-code-descriptions/
[11]: https://www.fec.gov/campaign-finance-data/committee-type-code-descriptions/
[12]: https://www.fec.gov/campaign-finance-data/party-code-descriptions/

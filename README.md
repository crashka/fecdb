# fecdb &ndash; database scripts for FEC bulk data #

## Project ##

### Introduction ###

This project contains simple scripts for the following:

* Downloading bulk data files from the FEC (Federal Election Committee) website
* Creating RDBMS (PostgreSQL) tables for the FEC data sets
* Loading the FEC bulk data into the database
* Indexes and views for supporting various queries against the database
* Sample SQL queries for exploring specific scenarios within the data

### Data Sets ###

The following data sets from the [FEC website][1] are currently supported:

| Name (with link) | FEC name | RDBMS table |
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

| Name (with link) | RDBMS table |
| --- | --- |
| [Transaction Type][10] | `transaction_type` |
| [Committee Type][11] | `cmte_type` |
| [Party][12] | `party` |

### Status ###

This is very early work, still in process.  In particular, indexes and views will be added as the specific semantics
of the data sets are better understood.  And sample queries will be added as various questions to answer are better
defined.

### To Do ###

* More documentation
* Create a real **To Do** list

## Requirements ##

The current package is depenent on the following:

* PostgreSQL 10
* A unix-like environment (e.g. bash, gawk, sed, etc.)
    * Not yet tested on cygwin, but that is planned
* Python 3

These should be installed in your environment before proceeding with the set up instructions below.

## Setting Things Up ##

*The following example steps show the process for dowloading and loading the 2020 election data (resulting in a ~600MB database).
All of the scripts support working with data from multiple elections years (named after the even years)&mdash;fuller documentation
to come.*

### Download data sets ###

    $ cd data
    $ ../scripts/wget_fec_data.sh 2020
    $ ls *.zip
    $ cd ..

*Note that the `wget_fec_data.sh` script is pretty basic, so only downloads into the current working directory*

### Create database and tables ###

    $ createdb fecdb
    $ psql -f sql/create_tables.sql fecdb

*Note that any of the command line database operations in this step (or following steps) can also be done equivalently
through a GUI (e.g. pgadmin).*

### Load data ###

    $ python3 scripts/load_fec_data.py all 2020 fecdb
    $ psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fecdb
    $ psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fecdb
    $ psql -c "\\copy party from 'data/party.txt'" fecdb

### Create indexes ###

    $ psql -f sql/create_indexes.sql fecdb

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

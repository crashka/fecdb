#!/bin/bash

set -x

dropdb fecdb
createdb fecdb
psql -ef sql/create_tables.sql fecdb

python3 scripts/load_fec_data.py all 2020,2018,2016,2014,2012,2010,2008,2006,2004,2002,2000 fecdb
psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fecdb
psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fecdb
psql -c "\\copy party from 'data/party.txt'" fecdb
psql -c "\\copy election_cycle from 'data/election_cycle.txt'" fecdb
psql -ef sql/load_indiv_tables.sql fecdb

psql -ef sql/create_indexes0.sql fecdb
psql -ef sql/analyze_tables0.sql fecdb
psql -ef sql/recreate_indiv_contrib.sql fecdb
psql -ef sql/create_indexes.sql fecdb
psql -ef sql/analyze_tables.sql fecdb

psql -ef sql/create_donor_support.sql fecdb
psql -ef sql/create_donor_seg_support.sql fecdb
psql -ef sql/create_indiv_seg_support.sql fecdb
psql -ef sql/create_name_parsing_support.sql fecdb

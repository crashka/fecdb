#!/bin/bash

set -x

dropdb fec16
createdb fec16
psql -ef sql/create_tables.sql fec16

python3 scripts/load_fec_data.py all 2016 fec16
psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fec16
psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fec16
psql -c "\\copy party from 'data/party.txt'" fec16
psql -c "\\copy election_cycle from 'data/election_cycle.txt'" fec16
psql -ef sql/load_indiv_tables.sql fec16

psql -ef sql/create_indexes0.sql fec16
psql -ef sql/analyze_tables0.sql fec16
psql -ef sql/recreate_indiv_contrib.sql fec16
psql -ef sql/create_indexes.sql fec16
psql -ef sql/analyze_tables.sql fec16

psql -ef sql/create_donor_support.sql fec16
psql -ef sql/create_donor_seg_support.sql fec16
psql -ef sql/create_indiv_seg_support.sql fec16
psql -ef sql/create_name_parsing_support.sql fec16

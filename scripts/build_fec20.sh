#!/bin/bash

set -x

dropdb fec20
createdb fec20
psql -ef sql/create_tables.sql fec20

python3 scripts/load_fec_data.py all 2020 fec20
psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fec20
psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fec20
psql -c "\\copy party from 'data/party.txt'" fec20
psql -ef sql/load_indiv_tables.sql fec20

psql -ef sql/create_indexes0.sql fec20
psql -ef sql/analyze_tables0.sql fec20
psql -ef sql/recreate_indiv_contrib.sql fec20
psql -ef sql/create_indexes.sql fec20
psql -ef sql/analyze_tables.sql fec20

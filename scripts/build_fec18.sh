#!/bin/bash

set -x

dropdb fec18
createdb fec18
psql -ef sql/create_tables.sql fec18

python3 scripts/load_fec_data.py all 2018 fec18
psql -c "\\copy transaction_type from 'data/transaction_type.txt'" fec18
psql -c "\\copy cmte_type from 'data/cmte_type.txt'" fec18
psql -c "\\copy party from 'data/party.txt'" fec18
psql -c "\\copy election_cycle from 'data/election_cycle.txt'" fec18
psql -ef sql/load_indiv_tables.sql fec18

psql -ef sql/create_indexes0.sql fec18
psql -ef sql/analyze_tables0.sql fec18
psql -ef sql/recreate_indiv_contrib.sql fec18
psql -ef sql/create_indexes.sql fec18
psql -ef sql/analyze_tables.sql fec18

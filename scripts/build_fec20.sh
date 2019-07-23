#!/bin/sh

dbname=fec20

createdb ${dbname}

psql -f create_tables.sql ${dbname}

for dataset in cn weball cm webk pas2 oth ccl indiv; do 
    psql -f load_${dataset}_data.sql ${dbname}
done

psql -f create_indexes.sql ${dbname}

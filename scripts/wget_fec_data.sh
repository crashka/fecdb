#!/bin/bash

usage() { printf "Error: $1\nUsage: $0 <elec_year>\n"; exit 1; }

if [[ $# -ne 1 || !($1 =~ ^[0-9]{4}$) ]]; then usage "bad argument(s)"; fi

FEC_DOMAIN=https://www.fec.gov
FILES_PATH=files/bulk-downloads

# TODO: could also accept list of data sets to download on the command line
DS_NAMES="cn weball cm webk pas2 oth ccl indiv"

year=$1
yr=${year:2:2}

for ds_name in ${DS_NAMES}; do
    wget ${FEC_DOMAIN}/${FILES_PATH}/${year}/${ds_name}${yr}.zip
done

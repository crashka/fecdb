#!/bin/bash

if [[ -z $1 || !($1 =~ ^[0-9]{4}$) ]]; then exit 1; fi

year=$1
yr=${year:2:2}

wget https://www.fec.gov/files/bulk-downloads/${year}/weball${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/cn${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/ccl${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/cm${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/webk${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/indiv${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/pas2${yr}.zip
wget https://www.fec.gov/files/bulk-downloads/${year}/oth${yr}.zip

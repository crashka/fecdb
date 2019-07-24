#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import subprocess
import sys

ZIP_FILE_FMT = '%s/%s%02d.zip'
UNZIP_TMPL   = 'unzip -p %s'
GAWK_TMPL    = 'gawk -F "|" -f %s/fmt_%s.awk'
SED_CMD      = 'sed "s/\\\\\\\\/\\\\\\\\\\\\\\\\/g"'
UNIQ_CMD     = 'uniq'
COPY_TMPL    = "copy %s from program '%s' with (format text, delimiter '|', null '')"
PSQL_ARGS    = ['psql', '-e']

FILE_DIR     = os.path.dirname(os.path.realpath(__file__))
BASE_DIR     = os.path.realpath(os.path.join(FILE_DIR, os.pardir))
SQL_DIR      = os.path.join(BASE_DIR, 'sql')
DATA_DIR     = os.path.join(BASE_DIR, 'data')
SCRIPT_DIR   = os.path.join(BASE_DIR, 'scripts')
CTBL_SQL     = os.path.join(SQL_DIR,  'create_tables.sql')
CIDX_SQL     = os.path.join(SQL_DIR,  'create_indexes.sql')

# data set record -- ds_name: (table, do_gawk, do_sed, do_uniq, data_file)
# NOTE: if do_gawk is True, then "fmt_<ds_name>.awk" must exist in SCRIPT_DIR
DATA_SETS  = {
    'cn'     : ('cand',          False, True, True,  None),
    'weball' : ('cand_fins',     True,  True, False, None),
    'cm'     : ('cmte',          False, True, True,  None),
    'webk'   : ('cmte_fins',     True,  True, False, None),
    'pas2'   : ('cmte_contrib',  True,  True, False, None),
    'oth'    : ('cmte_misc',     True,  True, False, None),
    'ccl'    : ('cand_cmte',     False, True, False, None),
    'indiv'  : ('indiv_contrib', True,  True, False, 'itcont.txt')
}

def load_data_set(elec_year, ds_names, db_name):
    for ds_name in ds_names:
        (table, do_gawk, do_sed, do_uniq, data_file) = DATA_SETS[ds_name]

        zip_file = ZIP_FILE_FMT % (DATA_DIR, ds_name, elec_year % 100)
        unzip_cmd = UNZIP_TMPL % (zip_file)
        if data_file:
            unzip_cmd += " " + data_file

        prog_pipeline = [unzip_cmd]
        if do_gawk:
            prog_pipeline.append(GAWK_TMPL % (SCRIPT_DIR, ds_name))
        if do_sed:
            prog_pipeline.append(SED_CMD)
        if do_uniq:
            prog_pipeline.append(UNIQ_CMD)

        copy_prog = ' | '.join(prog_pipeline)
        copy_sql  = COPY_TMPL % (table, copy_prog)
        psql_args = PSQL_ARGS + ['-c', copy_sql, db_name]
        subprocess.run(psql_args)

if __name__ == '__main__':
    def usage(msg):
        print("Error: %s\nUsage: %s {<data_set>[,...] | all} <elec_year>[,...] <db_name>" % (msg, sys.argv[0]))
        sys.exit(1)
    
    if len(sys.argv) != 4:
        usage("wrong number of arguments")

    data_set, elec_year, db_name = sys.argv[1:]
    if data_set == 'all':
        data_sets = DATA_SETS.keys()
    else:
        data_sets = data_set.split(',')
        for ds_name in data_sets:
            if ds_name not in DATA_SETS:
                usage("unknown data set \"%s\"" % (ds_name))

    for year in elec_year.split(','):
        load_data_set(int(year), data_sets, db_name)
    
    sys.exit(0)

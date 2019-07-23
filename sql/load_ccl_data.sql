copy cand_cmte
from program 'unzip -p /local/shared/fec/data/ccl20.zip | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

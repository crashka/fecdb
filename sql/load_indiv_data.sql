copy indiv_contrib
from program 'unzip -p /local/shared/fec/data/indiv20.zip itcont.txt | gawk -F "|" -f /local/shared/fec/scripts/fmt_indiv.awk | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

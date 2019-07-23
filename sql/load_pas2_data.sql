copy cmte_contrib
from program 'unzip -p /local/shared/fec/data/pas220.zip | gawk -F "|" -f /local/shared/fec/scripts/fmt_pas2.awk | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

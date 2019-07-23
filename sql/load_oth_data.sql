copy cmte_misc
from program 'unzip -p /local/shared/fec/data/oth20.zip | gawk -F "|" -f /local/shared/fec/scripts/fmt_oth.awk | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

copy cmte_fins
from program 'unzip -p /local/shared/fec/data/webk20.zip | gawk -F "|" -f /local/shared/fec/scripts/fmt_webk.awk | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

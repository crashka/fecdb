copy cand_fins
from program 'unzip -p /local/shared/fec/data/weball20.zip | gawk -F "|" -f /local/shared/fec/scripts/fmt_weball.awk | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

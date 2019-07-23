copy cand
from program 'unzip -p /local/shared/fec/data/cn20.zip | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

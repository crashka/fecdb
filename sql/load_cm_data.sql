copy cmte
from program 'unzip -p /local/shared/fec/data/cm20.zip | sed "s/\\\\/\\\\\\\\/g"'
with (format text, delimiter '|', null '')

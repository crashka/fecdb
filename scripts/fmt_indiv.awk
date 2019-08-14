BEGIN {
    now = systime()
    fmt  = "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n"
}

{
    date = ($14 ~ /^[0-9]{8}$/) ? mktime(substr($14, 5, 4) " " substr($14, 1, 2) " " substr($14, 3, 2) " 0 0 0") : 0
    datestr = (date > 0 && date < now) ? strftime("%Y-%m-%d", date) : ""
    # trim leading spaces from `name`--NOTE that this may inadvertently remove information in
    # some cases of malformed values (e.g. missing last nane, first name only), but probably
    # does more good than harm overall; we'll leave the other fields alone in this regard,
    # at least for now
    sub(/^ +/, "", $8)
    # this is not pretty, but collapse all repeated commas and spaces in `name`, and ensure
    # that commas are followed by a space (have to do it this way, since groups cannot be
    # specified in regexps)--as above, we may lose some information, but it's most likely
    # a decent tradeoff
    gsub(/,+/, ", ", $8)
    gsub(/ {2,}/, " ", $8)
    gsub(/ ,/, ",", $8)
    # upcase the following fields: name, city, state, zip_code, employer, occupation
    printf(fmt, $1, $2, $3, $4, $5, $6, $7, toupper($8), toupper($9), toupper($10),
           toupper($11), toupper($12), toupper($13), datestr, $15, $16, $17, $18,
           $19, $20, $21)
}

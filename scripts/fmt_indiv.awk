BEGIN {
    now = systime()
    fmt  = "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n"
}

{
    date = ($14 ~ /^[0-9]{8}$/) ? mktime(substr($14, 5, 4) " " substr($14, 1, 2) " " substr($14, 3, 2) " 0 0 0") : 0
    datestr = (date > 0 && date < now) ? strftime("%Y-%m-%d", date) : ""
    printf(fmt, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
           datestr, $15, $16, $17, $18, $19, $20, $21)
}

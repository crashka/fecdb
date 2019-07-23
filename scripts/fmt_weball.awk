BEGIN {
    now = systime()
    fmt  = "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n"
}

{
    date = ($28 ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) ? mktime(substr($28, 7, 4) " " substr($28, 1, 2) " " substr($28, 4, 2) " 0 0 0") : 0
    datestr = (date > 0 && date < now) ? strftime("%Y-%m-%d", date) : ""
    printf(fmt, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
           $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25,
           $26, $27, datestr, $29, $30)
}

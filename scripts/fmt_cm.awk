BEGIN {
    fmt  = "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n"
}

{
    # trim leading/trailing spaces and commas from `name`; NOTE that this may inadvertently
    # remove contextual information in certain cases of incomplete or malformed data (e.g.
    # missing first or last nane), but probably does more good than harm, overall; we'll
    # leave the other fields alone in this regard, at least for now
    sub(/^[ ,]+/, "", $2)
    sub(/[ ,]+$/, "", $2)
    # this is not pretty, but collapse all repeated commas and spaces in `name`, and ensure
    # that commas are followed by a space (have to do it this way, since groups cannot be
    # specified in regexps)--as above, we may lose some information, but it's most likely
    # a decent tradeoff; note that there are edge cases for which this sequences does not
    # work, but we won't worry about those at this point (we have unfixable problems with
    # data quality if they factor in to any appreciable extent)
    gsub(/,+/, ", ", $2)
    gsub(/ {2,}/, " ", $2)
    gsub(/ ,/, ",", $2)
    # trim double quotes (only if enclosing entire string)
    $2 ~ /^\".*\"$/ && sub(/^\"/, "", $2) && sub(/\"$/, "", $2)
    # collapse multiple single quotes (note: in some cases, doubled-up ticks should really
    # be converted to double quote, but it's not really possible to determine exactly when
    # this should be done, so we'll just assume the more common problem)
    gsub(/'{2,}/, "'", $2)
    # eliminate whitespace immediately inside of parentheses
    gsub(/\( /, "(", $2)
    gsub(/ \)/, ")", $2)

    # upcase the following fields: cmte_nm, tres_nm, cmte_st1, cmte_st2, cmte_city, cmte_st,
    # cmte_zip, connected_org_nm
    printf(fmt, $1, toupper($2), toupper($3), toupper($4), toupper($5), toupper($6), toupper($7),
           toupper($8), $9, $10, $11, $12, $13, toupper($14), $15)
}

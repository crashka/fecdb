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
    # collapse doubled-up apostrophes if embedded in a name part (note, will also convert
    # other instances in the name string, if they exist, but this is okay for now)
    $2 ~ /[A-Z]''[A-Z]/ && gsub(/''/, "'", $2)
    # ''BETO'' -> "BETO"
    gsub(/''/, "\"", $2)
    # convert proper name apostrophes to "|" (for preservation), isolate intended quotes
    # (assumes the two cases are not interspersed)
    $2 ~ /[A-Z]'[A-Z]/ && gsub(/'/, "\|", $2)
    # 'BETO' -> "BETO"
    gsub(/'/, "\"", $2)
    # restore proper name apostrophes
    gsub(/\|/, "'", $2)
    # ("ROCKY") or (ROCKY) -> "ROCKY"
    gsub(/\(\"?|\"?\)/, "\"", $2)
    # " IKE" -> "IKE" (assumes errant space is on leading side of quoted string)
    gsub(/ \" /, " \"", $2)
    #
    # upcase the following fields: cand_name, cand_st1, cand_st2, cand_city, cand_st, cand_zip
    printf(fmt, $1, toupper($2), $3, $4, $5, $6, $7, $8, $9, $10, toupper($11), toupper($12),
           toupper($13), toupper($14), toupper($15))
}

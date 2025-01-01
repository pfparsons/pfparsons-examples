#!/bin/false

pfp::is_numeric() {
    # $1 : Requried - value to be tested
    expr "$1" + 0 > /dev/null 2>&1
}


pfp::sanitize_name() {
    local -l in_fname="${1:?}"
    local -n out_fname="${2:?}"
    local -- prefix="${3:?}"

    if [ "${#in_fname}" -gt "0" ]
    then
        in_fname=${in_fname//_/}  # strip underscores
        in_fname=${in_fname// /_} # replace space with underscore
        in_fname=${in_fname//[^a-z0-9_]/} # strip non-alphanumeric
        out_fname="$prefix$in_fname"
        return 0
    else
        return 1
    fi
}
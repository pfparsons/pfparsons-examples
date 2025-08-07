#!/bin/false
#
# Main library script used to load other libs in shlibs.d

var::global_if_unset() {
    local -n nameref="${1:?}"
    local -- value="${2:?}"
    [[ "${nameref:-_undef_}" == "_undef_" ]] && nameref="$value"
}

var::export_if_unset() {
    local varname="${1:?}"
    local value="${2:?}"
    var::global_if_unset "$varname" "$value"
    export "$varname"
}

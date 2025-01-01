#!/bin/false
#
# Main library script used to load other libs in shlibs.d

# Apply defaults if undeclared or null
pfp::export_if_unset() {
    local -n _pfp_export_nref="${1:?}"
    local _pfp_export_value="${2:?}"

    if [ "${_pfp_export_nref:-_undef_}" == "_undef_" ]
    then
        export ${!_pfp_export_nref}="$_pfp_export_value"
    fi
}

pfp::export_if_unset "PFP_SHELL_LIB_DIR" "$(dirname $(realpath $BASH_SOURCE))"
pfp::export_if_unset "PFP_SCRIPTS_DIR" "$(dirname $PFP_SHELL_LIB_DIR)"
pfp::export_if_unset "PFP_BASE_DIR" "$(dirname $PFP_SCRIPTS_DIR)"
pfp::export_if_unset "PFP_CONFIG_DIR" "$PFP_BASE_DIR/config"

for lib in "$PFP_SHELL_LIB_DIR/base.d"/*
do
    . "$lib"
done


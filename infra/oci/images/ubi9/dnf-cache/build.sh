#!/bin/bash
# set -x
#
# DNF Local Cache for container builds


##############################################################################
function init() {
    local this_dir="$(dirname $(realpath ${BASH_SOURCE[0]}))"
    source "$this_dir/../scripts/init.sh"   
}


function main() {
    init || {
        echo "Failed to initialize $0"
        return 1
    }
    local tag="$(oci::derive_tag)"
    local image_ref="$(oci::image_tag "$tag")"
    local rpm_list_search_basedir="$(realpath ${BL_OCI_BUILD_CONTEXT}/..)"
    declare -a build_cmd
    fedora::prepare_build_cmd "build_cmd" "$image_ref" "$rpm_list_search_basedir"
    "${build_cmd[@]}"
}

main

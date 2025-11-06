#!/bin/bash

function print_rpm_list() {
    local basedir="${1:?}"

    declare -a rpms
    fedora::read_rpm_lists "rpms" "$basedir"

    echo "Union of all rpm lists under $basedir":
    echo "-------------------------------------"
    echo "${rpms[*]}"
    echo "-------------------------------------"
}

function print_build_cmd() {
    local tag="$(oci::derive_tag)"
    local image_ref="$(oci::image_tag "$tag")"

    local rpm_list_search_basedir="$(realpath ${BL_OCI_BUILD_CONTEXT}/..)"
    local -a cmd_array=()
    fedora::prepare_build_cmd "cmd_array" "$image_ref" "$rpm_list_search_basedir"

    echo "Build command for image '$image_ref':"
    echo "-------------------------------------"
    echo "${cmd_array[*]}"
    echo "-------------------------------------"
}

function main() {
    local -a this_dir="$(dirname $(realpath ${BASH_SOURCE[0]}))"
    local -a parent_dir="$(dirname "$this_dir")"
    source "$this_dir/init.sh"

    print_rpm_list "$parent_dir"
    print_build_cmd
}

main
#!/bin/false
#
# A collection of functions to help build fedora images

# ----------------------------------------------------------------------------
function fedora::read_rpm_lists() {
    shopt -s globstar
    local -n rpm_list="${1:?}"
    local -- basedir="${2:?}"
    
    basedir="$(realpath $basedir)"
    local -a fedora_dir="$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))"
    fs::is_subpath "$fedora_dir" "$basedir" || {
        return 1
    }

    local -a rpmfiles=("$basedir"/**/rpm-list.txt)
    local -a temp_rpms
    for f in ${rpmfiles[@]}
    do
        mapfile -t "temp_rpms" < "$f"
        rpm_list+=(${temp_rpms[@]})
    done
}

function fedora::prepare_build_cmd() {
    local -n cmd_array="${1:?}"
    local -- image_ref="${2:?}"
    local -- rpm_list_search_basedir="${3:-$BL_OCI_BUILD_CONTEXT}"

    declare -a rpms
    fedora::read_rpm_lists "rpms" "$rpm_list_search_basedir"

    local dnf_cache_image_ref="docker://$(oci::image_tag "fedora-dnf-cache")"

    cmd_array=(
        "podman"
        "build"
        "--tag" "$image_ref"
    )

    # If the list of RPMs is longer than a max size - split into chunks that
    # may be installed in separate layers - a crude method for avoiding large
    # image layers.
    local -i rpms_len="${#rpms[@]}"
    local -i max_chunk_size="8"
    if [[ "$rpms_len" -ge "$max_chunk_size" ]]
    then
    
        local -i num_chunks=$(( (rpms_len + max_chunk_size - 1) / max_chunk_size ))
        local -i start=0
        for (( i=0; i<num_chunks; i++ ))
        do
            local -i size="$max_chunk_size"
            local -i remaining="$(( rpms_len - start ))"
            if (( remaining < max_chunk_size ))
            then
                size="$remaining"
            fi
            local -a chunk=("${rpms[@]:start:size}")
            cmd_array+=("--build-arg" "RPMS_$((i+1))=${chunk[*]}")
            start=$((start + size))
        done
    else
        cmd_array+=("--build-arg" "RPMS_1=${rpms[*]}")
    fi

    cmd_array+=(
        "--build-context" "dnfcache=$dnf_cache_image_ref"
        "-f" "$BL_OCI_BUILD_CONTEXT/Containerfile"
        "$BL_OCI_BUILD_CONTEXT"
    )
}

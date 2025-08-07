

function lib::load_libs() {

    libs_dir="$(dirname $(realpath ${BASH_SOURCE[0]}))/lib.d"
    for lib in $libs_dir/*
    do
        source "$lib"
    done
}

function main() {
    export BL_SCRIPTS_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
    export BL_PROJECT_ROOT_DIR="$(dirname ${BL_SCRIPTS_DIR})"
    lib::load_libs
    var::export_if_unset BL_INITIALIZED "0"
}

main


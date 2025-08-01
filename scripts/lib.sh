
function lib::load_libs() {

    libs_dir="$(dirname $(realpath $BASH_SOURCE))/lib.d"
    for lib in $libs_dir/*
    do
        source "$lib"
    done
}

`lib::load_libs
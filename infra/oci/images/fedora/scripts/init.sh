function fedora::init() {
    local current_dir="$(dirname $(realpath $BASH_SOURCE[0]))"
    while [[ -z "$BL_INITIALIZED" ]] && [[ "$current_dir" != "/" ]]
    do
        local lib_loader="$current_dir/scripts/lib.sh"
        [[ -f "$lib_loader" ]] && [[ -r "$lib_loader" ]] && . "$lib_loader"
        current_dir="$(dirname $current_dir)"
    done;
    oci::init
}
    
fedora::init
function fedora::init() {
    local current_dir="$(dirname $(realpath $BASH_SOURCE[0]))"
    while [[ -z "$BL_INITIALIZED" ]] && [[ "$current_dir" != "/" ]]
    do
        local lib_script="$current_dir/scripts/lib.sh"
        [[ -f "$lib_script" ]] && [[ -r "$lib_script" ]] && {
          source "$lib_script"
        }
        current_dir="$(dirname $current_dir)"
    done;
    oci::init
}
    
fedora::init
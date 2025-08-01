
function init() {
    context_dir="$(dirname $(realpath $BASH_SOURCE))"
    staging_dir="${context_dir}/staging"

    local maybe_project_root="$context_dir"
    local maybe_scripts_dir

    while [[ -z "$BL_SCRIPTS_DIR" ]]
    do
        maybe_scripts_dir="$maybe_project_root/scripts"

        if [[ -d "$maybe_scripts_dir" ]] && [[ -r "$maybe_scripts_dir" ]]
        then # we found the scripts dir in the project root
            export BL_SCRIPTS_DIR="$maybe_scripts_dir"
            export BL_PROJECT_ROOT_DIR="$maybe_project_root"

        elif [[ "$maybe_project_root" == "/" ]]
        then # we traversed all the way to the fs root dir without success
            >&2 echo "ERROR: Unable to find scripts dir in any parent of " \
                     "$context_dir"

        else # try the parent dir 
            maybe_project_root="$(dirname $maybe_project_root)"
        fi
    done;

    . "$BL_SCRIPTS_DIR/lib.sh"
}

init
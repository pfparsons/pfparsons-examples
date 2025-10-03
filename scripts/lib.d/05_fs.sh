
function fs::is_subpath() {
    local parent="${1:?}"
    local child="${2:?}"
    [[ "$parent" == "$child" ]] || [[ "$child" == "$parent/"* ]]
}


##
# Reads lines from a file into an array, optionally filtering out commented lines.
#
# @description
#   Reads the contents of a file line by line into an array. If a comment character
#   is specified, lines beginning with that character (after optional whitespace) 
#   are excluded from the output array.
#
# @param {string} file_path Path to the file to read
# @param {string} lines_ref Name of array variable where lines will be stored
# @param {string} [comment_char] Optional character that marks comment lines
#
# @return {number} 0 on success, 1 if file not found
#
# @example
#   declare -a my_lines
#   fs::read_file_lines "config.txt" my_lines "#"
#
fs::read_file_lines() {
    local file_path="${1:?}"
    local -n lines_ref="${2:?}"
    local comment_chars="${3:-#}"  # Default to # if not specified

    if [[ ! -f "$file_path" ]]; then
        echo "File not found: $file_path" >&2
        return 1
    fi

    # Read file line by line, skipping comments
    lines_ref=()
    while IFS= read -r line; do
        # Skip empty lines and lines starting with comment chars (allowing for whitespace)
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*"$comment_chars" ]]; then
            lines_ref+=("$line")
        fi
    done < "$file_path"
}

declare -a rpm_list
fs::read_file_lines "/workspaces/pfparsons-examples/infra/oci/images/fedora/devcontainer/rpm-list.txt" rpm_list
echo "size: ${#rpm_list[@]} : ${rpm_list[*]}"


# TODO: keep or make into a function
# 1. Check for a paths file at $PFP_CONFIG_DIR/paths or /opt/pfp/config/paths
# 2. If found, perform variable substitution from the current environment to 
#    produce a list of paths
# to be prepended to the PATH environment variable. 
# - Before updating PATH, che

# paths_file="$PFP_CONFIG_DIR/paths"
# declare -a prepend_paths=($(envsubst "$paths_file"))
# IFS=':'
# read -ra existing_paths <<<"$PATH"
# unset IFS

# declare -A unique_paths
# declare -a new_paths=()

# for p in ${prepend_paths[@]} ${existing_paths[@]}
# do
#     if [ "${unique_paths[$p]:-_undef_}" == "_undef_" ]
#     then
#         unique_paths[$p]="$p"
#         new_paths+=($p)
#         i+=1
#     fi
# done

# IFS=':'
# export PATH="${new_paths[*]}"
# unset IFS
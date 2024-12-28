#!/bin/false
#
# 1. Check for a paths file at $PFP_CONFIG_DIR/paths or /opt/pfp/config/paths
# 2. If found, perform variable substitution from the current environment to 
#    produce a list of paths
# to be prepended to the PATH environment variable. 
# - Before updating PATH, che

paths_file="$PFP_CONFIG_DIR/paths"

declare -a prepend_paths=($(envsubst "$paths_file"))

IFS=':'
read -ra existing_paths <<<"$PATH"
unset IFS

declare -A unique_paths
declare -a new_paths=()

for p in ${prepend_paths[@]} ${existing_paths[@]}
do
    if [ "${unique_paths[$p]:-_undef_}" == "_undef_" ]
    then
        unique_paths[$p]="$p"
        new_paths+=($p)
        i+=1
    fi
done

IFS=':'
export PATH="${new_paths[*]}"
unset IFS

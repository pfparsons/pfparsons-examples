
function fs::is_subpath() {
    local parent="${1:?}"
    local child="${2:?}"
    [[ "$parent" == "$child" ]] || [[ "$child" == "$parent/"* ]]
}
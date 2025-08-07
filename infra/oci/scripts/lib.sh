
function oci::init() {
    var::global_if_unset BL_OCI_BUILD_CONTEXT "$(dirname $(realpath $0))"
    var::global_if_unset BL_OCI_DH_REGISTRY "docker.io"
    var::global_if_unset BL_OCI_DH_NAMESPACE "pfparsons"
    var::global_if_unset BL_OCI_DH_REPOSITORY "pfparsons-examples"
}

function oci::derive_tag() {
    local caller="$(dirname $(realpath ${BASH_SOURCE[1]}))"
    local tag="${caller#*/oci/images/}"
    tag="${tag//\//-}"
    echo "$tag"
}

# ----------------------------------------------------------------------------
function oci::image_tag() {
    local tag="${1:?}"
    echo "$BL_OCI_DH_REGISTRY/$BL_OCI_DH_NAMESPACE/$BL_OCI_DH_REPOSITORY:$tag"
}
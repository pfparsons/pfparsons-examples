this_dir="$(dirname "$(realpath "$0")")"

# ----------------------------------------------------------------------------
# Ensure that a git repository is cloned locally
#
# Arguments:
#  $1 - The URL of the git repository to clone
#  $2 - The local directory to clone into
# Returns:
#  0 if the repository is already cloned or was cloned successfully
#  non-zero if an error occurred
# ----------------------------------------------------------------------------
git::init_local() {
    local repo_url=${1:?}
    local dest_dir=${2:?}

    if [ ! -d "$dest_dir/.git" ]; then
        git clone "$repo_url" "$dest_dir"
    fi
}

main() {
    local this_dir="$(dirname "$(realpath "$0")")"
    local vcpkg_repo="https://github.com/microsoft/vcpkg.git"
    local src_dir="$this_dir/vcpkg"

    src_dir/bootstrap-vcpkg.sh -disableMetrics

    # TODO: figure out what to do instead of 
    # export VCPKG_ROOT=/path/to/vcpkg
    # export PATH=$VCPKG_ROOT:$PATH    

    # TODO: configure toolchain files
    # https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/cmake-integration#cmake_toolchain_file
    # Combining multiple...
    # https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/cmake-integration#using-multiple-toolchain-files

    # Checkout custon triplets at...
    # https://github.com/Neumann-A/my-vcpkg-triplets
    # conventions for naming https://developer.android.com/ndk/guides/other_build_systems

    # vcpkg.json reference
    # https://learn.microsoft.com/en-us/vcpkg/reference/vcpkg-json

    # vcpkg registry ui
    # https://vcpkg.link/

}
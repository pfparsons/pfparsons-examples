this_dir="$(dirname "$(realpath "$0")")"

spec="$this_dir/duckdb.spec"
source_dir="$HOME/rpmbuild/SOURCES/"
mkdir -p source_dir

rpm_buildroot="$this_dir/buildroot"
mkdir -p "$buildroot"
spectool -g -C "$source_dir" "$spec"
rpmbuild -bb  --buildroot="$buildroot" "$this_dir/duckdb.spec"
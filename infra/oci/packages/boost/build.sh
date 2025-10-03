

get_latest_boost_tag() {
    git ls-remote --tags https://github.com/boostorg/boost.git | \
    grep -E 'refs/tags/boost-[0-9]+\.[0-9]+\.[0-9]+$' | \
    sed 's|.*refs/tags/||' | \
    sort -V | \
    tail -n 1
}


BOOST_TAG=$(get_latest_boost_tag)
echo "Using Boost tag: $BOOST_TAG"
git clone --recursive https://github.com/boostorg/boost.git
#cd boost
#git checkout develop # or whatever branch you want to use
#./bootstrap.sh
#./b2 headers

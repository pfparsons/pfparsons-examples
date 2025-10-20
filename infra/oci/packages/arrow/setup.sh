#!/bin/bash



function init() {
        script_dir="$(dirname $(realpath ${BASH_SOURCE[0]}))"
        script_name="$(basename ${BASH_SOURCE[0]})"
        
        buildroot_dir="$script_dir/buildroot"
        mkdir -p "$buildroot_dir"
}

function ensure_empty_dir() {
    local dir="${1:?}"

    if [[ "$dirname" != "$buildroot_dir"* ]]; then
        echo "ERROR: ensure_empty_dir called on path outside buildroot" >&2
        echo "    buildroot: $buildroot_dir" >&2
        echo "  invalid dir: $dir" >&2
        return 1
    fi

    if [[ -d "$dir" ]]; then
        rm -rf "$dir" || {
            echo "ERROR: Unable to clean dir: $dir" >&2
            return 1
        }
    fi

    mkdir -p "$dirname"
}


function make_clean_all_dirs() {

        src_dir="$script_dir/buildroot/src"


        arrow_src_dir="$src_dir/arrow"
        mkdir -p "$arrow_src_dir"

        py_dir="$buildroot/python"
        py_venv_dir="$py_dir/venv"
        mkdir -p "$py_venv_dir"

        cpp_dir="$buildroot/cpp"
        
        arrow_cpp_src_dir="$arrow_src_dir/cpp"
        arrow_cpp_build_dir="$cpp_dir/build"
        mkdir -p "$arrow_cpp_build_dir"
        arrow_cpp_dist_dir="$cpp_dir/dist"
        mkdir -p "$arrow_cpp_dist_dir"
}


function python::venv_ok {
    [[ "$(type -t "deactivate")" == "function" ]] || {
        return 1
    }
    [[ "$VIRTUAL_ENV" == "$py_venv_dir" ]] || {
        return 1
    }
    [[ "$(command -v python)" == "$py_venv_dir/bin/python" ]] || {
        return 1
    }    
    return 0
}



function python::ok() {
    python::venv_ok || {
        return 1
    }
    [[ "$(command -v uv)"  ]] || {
        return 1
    }
    [[ "uv pip install -r $pyarrow_src_dir/requirements-build.txt" ]]


}


function print_vars() {
    local -a varnames=(
        "script_name"
        "script_dir"
        "arrow_src_dir"
        "venv_dir"
        "arrow_cpp_src_dir"
        "arrow_cpp_dist_dir"
        "arrow_cpp_build_dir"
        "ARROW_HOME"
        "CMAKE_PREFIX_PATH"
    )

    echo "Variables:"
    echo "------------------------"
    for v in ${varnames[@]}; do
        echo "$v=\"${!v}\""
    done
    echo "------------------------"
}


function python_venv() {
    python3 -m venv "$venv_dir"
    source "$venv_dir/bin/activate"
    pip install -r "arrow_src_dir/python/requirements-build.txt"
}


function setup_cpp() {
    mkdir -p "$arrow_cpp_dist_dir"

    export ARROW_HOME="$arrow_cpp_dist_dir"
    export LD_LIBRARY_PATH="$ARROW_HOME/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$ARROW_HOME:$CMAKE_PREFIX_PATH"

    cmake -S $arrow_src_dir/cpp -B arrow/cpp/build \
            -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
            --preset ninja-debug-python    

    export VCPKG_DEFAULT_TRIPLET="x64-linux"

    declare -a cmake_setup_cmd=(
        cmake 
        -S $arrow_cpp_src_dir
        -B "$HOME/builds/arrow/python-debug" 
        --preset ninja-debug-python 
        -DARROW_DEPENDENCY_SOURCE=VCPKG
    )
}


function build_cpp {
    cmake --build "$arrow_cpp_build_dir" --target install
}


function print_help() {
    echo "Usage:"
    echo "  $script_name [setup|clean|build]"
}

init

if [[ "$#" -lt 1 ]]; then
    echo "Missing required argument."
    print_help
    exit 1
fi



while [[ $# -gt 0 ]]; do
  case $1 in
    setup)
      print_vars
      shift # past argument
      ;;
    clean)
      shift # past argument
      ;;
    build)
      shift # past argument
      ;;
    *)
      echo "Unknown option $1"
      print_help
      exit 1
      ;;
  esac
done


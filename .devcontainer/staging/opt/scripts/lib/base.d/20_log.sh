# define logging functions that echo formatted output to stdout and stderr

declare -A pfp_log_levels=(
    ["fatal"]="1"
    ["error"]="2"
    ["info"]="4"
    ["debug"]="5"
    ["warn"]="3"
)

declare -A pfp_log_level_names

declare -A pfp_log_colors=(
    ["fatal"]="$color_bg_red$color_fg_white"
    ["error"]="$color_bg_red$color_fg_bright_yellow"
    ["warn"]="$color_fg_yellow"
    ["info"]="$color_fg_green"
    ["debug"]="$color_fg_gray"
)

declare -ix pfp_current_log_level="${pfp_log_levels['debug']}"

## TODO log redirection
# exec 3<> /tmp/foo  #open fd 3.
# echo "test" >&3
# exec 3>&- #close fd 3.
# https://tldp.org/LDP/abs/html/io-redirection.html


pfp::log () {
    local -i _log_level="${1:?}" # Integer log level
    local -- _log_msg="${2:?}" # Log message

    if ! pfp::is_numeric $_log_level
    then
        echo "LOGGING ERROR - non-numeric log_level supplied" 1>&2
    fi

    if [ "$pfp_current_log_level" -ge "$_log_level" ]
    then
        if [ "$pfp_current_log_level" -ge "${pfp_log_levels['debug']}" ]
        then
            # Log message prefix: timestamp [log level] src_dir/file:00
            local -- _ts="$(date +%FT%k:%M:%S-%Z)"
            local -- _prefix="$color_fg_gray$_ts$color_reset"
            local -- _level_name="${pfp_log_level_names[$_log_level]}"
            local -- _level_label="${pfp_log_colors[$_level_name]}"
            _level_label+="$(align::left 5 $_level_name)$color_reset"
            local -- _prefix+=" [$_level_label]"

            local -i _log_stack_offset="${pfp_log_stack_offset:-2}"
            local -- _fn="${FUNCNAME[$_log_stack_offset]}"
            local -- _src_path="$(realpath ${BASH_SOURCE[$_log_stack_offset]})"
            local -- _src_abs_dir="$(dirname $_src_path)"
            local -- _src_dir="$(basename $_src_abs_dir)"
            _src_abs_dir="$(dirname $_src_abs_dir)"
            while [ "$_src_abs_dir" != "$PFP_BASE_DIR"  ]
            do
                _src_abs_dir="$(dirname $_src_abs_dir)"
                _src_dir="$(basename $_src_abs_dir)/$_src_dir"
            done
            _prefix+=" $color_fg_gray$_src_dir/"

            local -- _src_line_num="${BASH_LINENO[$((_log_stack_offset - 1))]}"
            _prefix+="$color_fg_yellow$(basename $_src_path)"
            _prefix+="$color_fg_gray:$(align::left 4 $_src_line_num)"
            _prefix+="$color_reset"
        else
            # Log message prefix - timestamp and log level
            local -- _level_name="${pfp_log_level_names[$_log_level]}"
            local -- _prefix="[$(align::left 5 $_level_name)]"
        fi
        printf "$_prefix: $_log_msg\n"

    fi
}

pfp::log::init(){
    # initialize pfp_log_level_names
    pfp_log_level_names=()
    for n in "${!pfp_log_levels[@]}"
    do
        local -i level_num="${pfp_log_levels[$n]}"
        pfp_log_level_names[$level_num]="$n"
    done
    unset level_num

    # Unset any functions beginning with pfp_log_
    local -- _declare_prefix="declare -f "
    local -a _log_functions=()    
    for fn in $(declare -F)
    do
        fn="${fn/$_declare_prefix}"
        if [ "${fn[@]:0:8}" == "pfp_log_" ]
        then
            unset "$fn"
        fi
    done

    # Iterate over the pfp_log_levels array and recreate pfp_log_[level] funcs
    for level_name in ${!pfp_log_levels[@]}
    do
        fn_name=""
        if pfp::sanitize_name "$level_name" "fn_name" "pfp::log_"
        then
            local -a fn_decl=(
                "$fn_name()" "{"
                    "local" "-i" "log_level_num=\"${pfp_log_levels[$level_name]}\"" ";"
                    "pfp::log" "\"\$log_level_num\"" "\"\$1\"" ";"
                "}"
            )
            eval "${fn_decl[*]}"
        else
            pfp::log 1 "Error initializing loggers - bad log level name \"$level_name\""
        fi
    done
}

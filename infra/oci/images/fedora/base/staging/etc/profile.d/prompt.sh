#!/bin/false

fg_red="$(tput setaf 1)"
fg_blue="$(tput setaf 4)"
fg_green="$(tput setaf 6)"
fg_brgreen="$(tput setaf 10)"
fg_yellow="$(tput setaf 11)"
fg_white="$(tput setaf 15)"
fg_gray="$(tput setaf 8)"
rst="$(tput sgr0)"



export VIRTUAL_ENV_DISABLE_PROMPT=1

dc_get_venv_label() {
    # if a virtual environment is activated, make a label string suitable for
    # displaying in the prompt to indicate a specific venv is activated. Set
    # the label text based on the parent folder of the venv.
    #
    # $1 outvar : variable name to assign the virtual env prompt label
    [[ "$#" -lt 1 ]] && {
        >&2 echo "Fucntion dc_get_venv_label called without 1 required arg"
        return 1
    }

    local -n _venv_nref="$1"
    local _venv_str=""

    if [[ -n "$VIRTUAL_ENV" ]]; then
      _venv_str=$(dirname $VIRTUAL_ENV)
      _venv_str="${_venv_str##*/}"
    fi

    _venv_nref="$_venv_str"
}


dc_pre_prompt() {

    local _venv_label_clr="$fg_brgreen"
    local _pwd_clr="$fg_yellow"
    local _usrhost_clr="$fg_green"
    local _time_clr="$fg_blue"


    if [ -z "$COLUMNS" ]
    then
      COLUMNS=$(tput cols)
    fi

    local _breakpoint="83"
    local _pwd="$PWD"
    local _venv_label=""
    local _venv=""
    dc_get_venv_label "_venv_label"
    if [ -n "$_venv_label" ]
    then
        _venv="venv: $_venv_label | "
    fi
    local _userhost="$USER @ $HOSTNAME"
    local _time="$(date)"
    local _ps1l=""
    local _ps1r=""


    if [ "$((COLUMNS - _breakpoint))" -lt "${#_pwd}" ]
    then
        _pwd=$(sed -e "s:$HOME:~:" -e "s:\(\.\?[^/]\)[^/]*/:\1/g" <<<"$_pwd" )
    fi


    _ps1l="$_venv$_pwd"

    local _psrpad="$((COLUMNS - ${#_ps1l}))"

    if [ -z "$NO_COLOR" ]
    then
        if [ -n "$_venv_label" ]
        then
            _venv="${fg_gray}venv: $_venv_label_clr$_venv_label$rst | "
        fi
        _pwd="$_pwd_clr$_pwd$rst"
        _userhost="$_usrhost_clr$_usrhost$rst"
        _time="$_time_clr$_time$rst"
        _ps1l="$_venv$_pwd"
    fi

    if [ "$((COLUMNS - ${#_pwd}))" -gt "$_breakpoint" ]
    then
        _ps1r="$_usrhost  $_time"
    fi


    printf "%s%${_psrpad}s" "$_ps1l" "$_ps1r"
}

PROMPT_COMMAND=dc_pre_prompt
export PS1="\n > "

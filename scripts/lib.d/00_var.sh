#!/bin/false
#
# Main library script used to load other libs in shlibs.d

var::global_if_unset() {
    local -n nameref="${1:?}"
    local -- value="${2:?}"
    [[ "${nameref:-_undef_}" == "_undef_" ]] && nameref="$value"
}

var::export_if_unset() {
    local varname="${1:?}"
    local value="${2:?}"
    var::global_if_unset "$varname" "$value"
    export "$varname"
}

array::split() {
  local -n out_array="${1:?}"
  local input_string="${2:?}"
  local delimiter="$3"

  if [[ -z "$delimiter" ]]
  then
      unset IFS
  else
      IFS="$delimiter"
  fi
  read -ra out_array <<<"$input_string"
  unset IFS
}


set::union() {
  local -n in_a="${1:?}"
  local -n in_b="${2:?}"
  local -n out="${3:?}"
  local -A distinct_map 
  unset IFS
  local -a tmp=()
  for el in "${in_a[@]}" "${in_b[@]}"
  do
      if [[ -z "${distinct_map[$el]}" ]]
      then
          distinct_map[$el]="1"
          tmp+=( "$el" )
      fi
  done
  out=( "${tmp[@]}" )
}
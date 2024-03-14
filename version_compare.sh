#!/usr/bin/env bash

#
# @file
# Quickly lists versions of installed custom modules against repository versions.
#

# Define the configuration file relative to this script.
CONFIG="version_compare.core.yml"

COMPOSER_VENDOR=""

# Uncomment this line to enable file logging.
#LOGFILE="version_compare.core.log"

# TODO: Event handlers and other functions go here or register one or more includes in "additional_bootstrap".
function on_pre_config() {
  [[ "$(get_command)" == "init" ]] && exit_with_init
}

# Echo the composer package name (if available)
#
# Returns 1 if not found.
function echo_composer_name() {
  if [ -f composer.json ]; then
    json_load_file composer.json
    name="$(json_get_value "name")"
    [[ "$name" ]] && echo "$name" && return 0
  fi
  return 1
}

function echo_version() {

  if [ -f *.info.yml ]; then
    yaml_set "$(cat *.info.yml)"
    json_set "$(yaml_get_json)"
    version="$(json_get_value "version")"
    [[ "$version" ]] && echo "$version" && return 0
  fi
  # TODO Read from .info file, i.e., D7.

  if [ -f composer.json ]; then
    json_load_file composer.json
    version="$(json_get_value "version")"
    [[ "$version" ]] && echo "$version" && return 0
  fi

  if [ -f package.json ]; then
    json_load_file package.json
    version="$(json_get_value "version")"
    [[ "$version" ]] && echo "$version" && return 0
  fi

  version=$("$HOME/bin/web_package" v | tail -n1)
  [[ "$version" ]] &&  echo "$version" && return 0

  echo "?"
  return 1
}

# Echo a JSON string of version info.
#
# $1 - string The module name
#
# Returns 0 if .
function get_project_version_json() {
  local module="$1"

  # We can't compare a nameless or missing module.
  if ! [[ "$module" ]] || [ ! -e "$project_dir/$module" ]; then
    echo '{}'
    return 1
  fi

  local installed_version=$(cd "$project_dir/$module" && echo_version)
  local composer=$(cd "$project_dir/$module" && echo_composer_name)

  # If not in the library we can't compare.
  if [ ! -e "$library_dir/$module" ]; then
    echo "{\"name\":\"$module\",\"composer\":\"$composer\",\"path\":\"$project_dir/$module\",\"status\":\"1\",\"version\":\"$installed_version\",\"available\":\"\"}"
    return 0
  fi

  local lib_version=$(cd "$library_dir/$module" && echo_version)

  local status=0
  if [[ "$installed_version" == "$lib_version" ]]; then
    status=1
  fi

  echo "{\"name\":\"$module\",\"composer\":\"$composer\",\"path\":\"$project_dir/$module\",\"status\":\"$status\",\"version\":\"$installed_version\",\"available\":\"$lib_version\"}"
  return 0
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}"
while [ -h "$s" ]; do
  dir="$(cd -P "$(dirname "$s")" && pwd)"
  s="$(readlink "$s")"
  [[ $s != /* ]] && s="$dir/$s"
done
r="$(cd -P "$(dirname "$s")" && pwd)"
source "$r/../../cloudy/cloudy/cloudy.sh"
[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

# Handle other commands.
command=$(get_command)
case $command in

"show")
  eval $(get_config_path_as "project_dir" "installed_modules" )
  eval $(get_config_path_as "library_dir" "source_modules" )

  echo_title "Reviewing Custom Modules"
  echo_heading $(path_relative_to_pwd "$project_dir")
  list_clear

  todos=()
  directories=("$project_dir"/*)
  i=1
  for directory in ${directories[@]}; do
    if [ -d "$directory" ]; then
      project_name=${directory##*/}
      json_set "$(get_project_version_json "$project_name")"

      id=""
      # The ID may come from composer.json#/name...
      id=$(json_get_value "composer")
      # ... or it may come from the name key from other files.
      [[ ! "$id" ]] && id=$(json_get_value "name")
      [[ ! "$id" ]] && $(basename $project_name)

      bullet=$LI
      [ $i -eq ${#directories[@]} ] && bullet=$LIL

      if [[ $(json_get_value "status") != '1' ]]; then
        available="$(json_get_value "available")"
        todos=("${todos[@]}" "$id:$available")
        echo $bullet "$(echo_red_highlight "$id:$(json_get_value "version") -> $available")"
      else
        echo "$bullet $id:$(json_get_value "version")"
      fi
    fi
    ((i++))
  done

  echo
  echo_heading "todos.md"
  for item in "${todos[@]}"; do
    echo "- Update to $item"
  done

  has_failed && exit_with_failure
  exit_with_success "Version check complete."
  ;;

esac

throw "Unhandled command \"$command\"."

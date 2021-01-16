#!/usr/bin/env bash

#
# @file
# Quickly lists versions of installed custom modules against repository versions.
#

# Define the configuration file relative to this script.
CONFIG="version_compare.core.yml"

# Uncomment this line to enable file logging.
#LOGFILE="version_compare.core.log"

# TODO: Event handlers and other functions go here or register one or more includes in "additional_bootstrap".
function on_pre_config() {
  [[ "$(get_command)" == "init" ]] && exit_with_init
}

function echo_version() {
  version=$("$HOME/bin/web_package" v | tail -n1)
  if [[ ! "$version" ]]; then
    echo "(not found)"
  fi
  echo "$version"
}

function compare() {
  local module="$1"

  # We can't compare a nameless module.
  if ! [[ "$module" ]]; then
    return 1
  fi

  # If not in the library we can't compare.
  if [ ! -e "$library_dir/$module" ]; then
    return 1
  fi

  local installed_version=$(cd "$project_dir/$module" && echo_version)
  local lib_version=$(cd "$library_dir/$module" && echo_version)

  if [[ "$installed_version" == "$lib_version" ]]; then
    echo "$module: $installed_version -> $lib_version"
  else
    echo_red_highlight "$module: $installed_version -> $lib_version"
  fi
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

  echo_title "Checking custom modules versions in:  $project_dir..."
  echo_heading "Project: Installed version -> Available Version"
  list_clear
  for module in "$project_dir"/*; do
    if [ -d "$module" ]; then
      project_name=${module##*/}
      list_add_item "$(compare "$project_name")"
    fi
  done
  echo_list
  has_failed && exit_with_failure
  exit_with_success "Version check complete."
  ;;

esac

throw "Unhandled command \"$command\"."

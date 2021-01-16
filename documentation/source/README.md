# Version Compare

![version_compare](images/version-compare.jpg)

## Summary

Quickly lists versions of installed custom modules against repository versions.

**Visit <https://aklump.github.io/version_compare> for full documentation.**

## Quick Start

- Install in your repository root using `cloudy pm-install aklump/version_compare`
- Open _bin/config/version_compare.yml_ and modify as needed.
- Open _bin/config/version_compare.local.yml_ and ...; be sure to ignore this file in SCM.
- Try it out with `./bin/version_compare SOME_COMMAND`

## Requirements

You must have [Cloudy](https://github.com/aklump/cloudy) installed on your system to install this package.

## Installation

The installation script above will generate the following structure where `.` is your repository root.

    .
    ├── bin
    │   ├── version_compare -> ../opt/version_compare/version_compare.sh
    │   └── config
    │       ├── version_compare.yml
    │       └── version_compare.local.yml
    ├── opt
    │   ├── cloudy
    │   └── aklump
    │       └── version_compare
    └── {public web root}

    
### To Update

- Update to the latest version from your repo root: `cloudy pm-update aklump/version_compare`

## Configuration Files

Refer to the file(s) for documentation about configuration options.

| Filename | Description | VCS |
|----------|----------|---|
| _version_compare.yml_ | Configuration shared across all server environments: prod, staging, dev  | yes |
| _version_compare.local.yml_ | Configuration overrides for a single environment; not version controlled. | no |

## Usage

* To see all commands use `./bin/version_compare`

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Fversion_compare).

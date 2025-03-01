#!/usr/bin/env nu

# This module provides a function to update the version of pylyzer in the project
# when new tags are detected on PYPI.
#
# Running the script will:
# 
# Usage as a library:
#   use mirror.nu *
#   let new_tag = get-latest-version-from-pypi
#   update-version-in-file $new_tag


# Return the latest version of pylyzer published on pypi
export def get-latest-version-from-pypi []: any -> string {
    let data = http get https://pypi.org/pypi/pylyzer/json
    $data.info.version
}

# Return the current version of pylyzer currently used
export def get-current-version []: any -> string {
    open pyproject.toml --raw
    | parse --regex 'pylyzer==v?(\d+\.\d+\.\d+)'
    | get capture0
    | first
}

# Updates the version of pylyzer in a file.
# 
# Arguments:
# - new_tag (string): the new version tag (e.g., "1.2.3").
export def update-version-in-file [file: path, new_tag: string] {
    open $file --raw
    | str replace --regex --all 'v\d+\.\d+\.\d+' $'v($new_tag)'
    | save $file --force;
}

def main [] {
    let current_tag = get-current-version;
    print $"Current tag: ($current_tag)";
    let latest_version_from_pypi = get-latest-version-from-pypi;
    print $"Latest version on PYPI: ($latest_version_from_pypi)";
    # update-version-file pyproject.toml $new_tag;
    # update-version-file README.md $new_tag;
}

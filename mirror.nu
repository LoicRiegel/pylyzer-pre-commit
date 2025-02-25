#!/usr/bin/env nu

# This module provides a function to update the version of pylyzer in the project's requirements.
#
# Usage:
#   - nu mirror.nu 'v1.2.3'
#   - use mirror.nu *
#     update_pylyzer_version Ã$new_tag

# Updates the version of pylyzer in pyproject.toml's requirements.
# 
# Arguments:
# - new_tag (string): the new version tag (e.g., "v1.2.3").
export def update_pylyzer_version [new_tag: string] {
    open pyproject.toml --raw
    | str replace -r 'pylyzer==v?\d+\.\d+\.\d+' $'pylyzer==($new_tag)'
    | save pyproject.toml --force
}

def main [new_tag: string] {
    update_pylyzer_version $new_tag
}


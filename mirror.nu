#!/usr/bin/env nu

# This module provides a function to update the version of pylyzer in the project
# when new tags are detected on PYPI.
#
# Note: tags on GitHub are formatted as 'v1.2.3' whereas versions on PYPI are as '1.2.3'
#
# Running the script:
#   - fetch the latest version tag of pylyzer published on PYPI
#   - if this version is greater than the current version, update the version in pyproject.toml and README
#   - create a new commit message and tag it
#
# Usage as a library:
#   use mirror.nu *
#   let new_version = get-latest-version-from-pypi
#   update-version-in-readme $new_version


# Return the latest version of pylyzer published on pypi
export def get-latest-version-from-pypi []: any -> string {
    let data = http get https://pypi.org/pypi/pylyzer/json;
    $data.info.version
}

# Return the current version of pylyzer currently used
export def get-current-version []: any -> string {
    open pyproject.toml --raw
    | parse --regex 'pylyzer==(\d+\.\d+\.\d+)'
    | get capture0
    | first
}

# Updates the version of pylyzer in the README.
#
# Arguments:
# - new_tag (string): the new tag (e.g., 'v1.2.3').
export def update-version-in-readme [new_tag: string] {
    let file = 'README.md';
    open $file --raw
    | str replace --regex --all 'rev: v\d+\.\d+\.\d+' $'rev: ($new_tag)'
    | save $file --force;
}

# Updates the version of pylyzer in pyproject.toml.
#
# Arguments:
# - new_version (string): the new version tag (e.g., '1.2.3').
export def update-version-in-pyproject [new_version: string] {
    let file = 'pyproject.toml';
    open $file --raw
    | str replace --regex --all 'pylyzer==\d+\.\d+\.\d+' $'pylyzer==($new_version)'
    | save $file --force;
}

# Create the git tag based on the pylyzer version from PYPI
export def create-tag-from-version [version: string]: any -> string {
    $'v($version)'
}

# Default commit message based on the new tag of pylyzer
export def create-commit-msg [version: string]: any -> string {
    $'Mirror: ($version)'
}

export def create-gh-release [] {
    let tag = git tag | lines | last;
    gh release create $tag --title $tag --notes $'See notes at https://github.com/mtshiba/pylyzer/releases/tag/($tag)' --latest;
}

# Test the pre-commit
export def test-hook [] {
    do {
        cd test;
        try {
            pre-commit try-repo ../ pylyzer --all-files --verbose;
            print 'Hook test passed'
        } catch {
            print 'Hook test failed! This might indicate that this version of pylyzer cannot be used with pre-commit'
        }
    };
}

# Main script
#
# Arguments:
# - push: whether to perform git push and create GitHub release
def main [--push = true] {
    let current_version = get-current-version;
    print $'Current tag: ($current_version)';
    let latest_version_from_pypi = get-latest-version-from-pypi;
    print $'Latest version on PYPI: ($latest_version_from_pypi)';

    if $latest_version_from_pypi <= $current_version {
        print 'No new tag of pylyzer has been published on PYPI';
        return;
    }

    let new_tag = create-tag-from-version $latest_version_from_pypi
    print 'A new tag has been published: creating a commit and tag';
    update-version-in-pyproject $latest_version_from_pypi;
    update-version-in-readme $new_tag;

    print "Testing hook with pylyzer's new version";
    test-hook;

    let commit_msg = create-commit-msg $latest_version_from_pypi;
    git add pyproject.toml README.md;
    git commit -m $commit_msg;
    git tag $new_tag;
    if $push == true {
        print 'Pushing new commit and tag';
        git push;
        git push --tags;
        create-gh-release;
    } else {
        print 'A commit and a tag were created but not pushed';
    }
}

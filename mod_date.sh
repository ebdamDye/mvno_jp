#!/bin/bash

# config

# init

# fail-safe
set -eu

# subroutines
function chk_path () {
    if ! [ -e "$1" ] ; then
        echo "$1 not found."
        cd "$CUR_DIR"
        exit 1
    fi
}

function mod_date () {
    local STR_DATE=`git log -n 1 --follow --diff-filter=AM --pretty=format:"%ci" "$1"`
    local MOD_DATE=`date --utc +%FT%TZ -d "$STR_DATE"`

    touch --date="$MOD_DATE" "$1"
}

# main
while :
do
    chk_path "$1"
    mod_date "$1"

    [ "$#" == 1 ] && exit 0
    shift
    continue
done

#!/bin/bash

# config
URL="https://ebdamdye.github.io/mvno_jp/"
HOME="index.html"
SITEMAP="sitemap.xml"
LOC_ROOT="docs"

# init
GIT_ROOT=`dirname $0`
DOC_ROOT="${GIT_ROOT}/${LOC_ROOT}"
CUR_DIR=`pwd`

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

function get_date_commit () {
    local STR_DATE=`ls -l --time-style=full-iso "$1" | awk '// { print $6 " " $7 " " $8 }'`

    MOD_DATE=`date --utc +%FT%TZ -d "$STR_DATE"`
}

function get_date_publish () {
    local STR_DATE=`awk '
    /^<p class="date"/ {
        gsub( /^.*Created: /, "" )
        gsub( /<.*$/, "" )
        print
        exit
    }' "$1"`
    MOD_DATE=`date --utc +%FT%TZ -d "$STR_DATE"`
}

function out_url_tag () {
    echo "  <url>
    <loc>$1</loc>
    <lastmod>$2</lastmod>
    <priority>$3</priority>" >> "$SITEMAP"
    echo '  </url>' >> "$SITEMAP"
}

function out_url_img () {
    while [ -n "$1" ] ; do
        chk_path "$1"
        get_date_commit "$1"
        out_url_tag "${URL}/${1}" "$MOD_DATE" "0.5000"

        [ "$#" == 1 ] && return
        shift
    done
}

function out_url_htm () {
    while [ -n "$1" ] ; do
        chk_path "$1"

        get_date_publish "$1" # set MOD_DATE
        if [ "$1" == "$HOME" ] ; then
            out_url_tag "${URL}/" "$MOD_DATE" "1.0000"
        else
            out_url_tag "${URL}/${1}" "$MOD_DATE" "0.5000"
        fi

        #get_img_list "$1" # set $IMG_LIST
        #out_img_tag $IMG_LIST

        [ "$#" == 1 ] && return
        shift
    done
}

function out_header () {
    echo '<?xml version="1.0" encoding="UTF-8"?>
<urlset
  xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                      http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">' > "$SITEMAP"

    # require <image:image>
#    echo '<?xml version="1.0" encoding="UTF-8"?>
#<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
# xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">' > "$SITEMAP"
}

function out_footer () {
    echo '</urlset>' >> "$SITEMAP"
}

# main
cd "$DOC_ROOT"

chk_path "$HOME"
[ -e "$SITEMAP" ] && cp -p "$SITEMAP" "$SITEMAP".old

out_header
out_url_htm "$HOME"
#out_url_img `ls *.png`
out_footer

git add "$HOME" "$SITEMAP"

[ -e "${SITEMAP}.old" ] && rm "${SITEMAP}.old"
cd "$CUR_DIR"

echo "$SITEMAP updated."


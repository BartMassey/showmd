#!/bin/sh
# Format markdown on Debian Linux in new browser tab or to stdout.
# Bart Massey 2021-04

# Dependencies:
#     xdg-utils
#     pandoc: not required, but highly desirable
#     markdown: for "Classic" markdown
#     multimarkdown: for "Classic" multimarkdown; also
#       supplies its own version of "Classic" markdown, so
#       you can't have both markdown and multimarkdown
#       installed simultaneously (ugh)

# "Classic" markdown doesn't handle utf-8 properly.  It also
# doesn't handle LaTeX math at all.  By default I instead
# use the excellent markdown engine of
# [pandoc](https://pandoc.org/).

# Debian pandoc uses a local copy of
# [mathjax](https://www.mathjax.org/), which will only exist
# if libjs-mathjax is installed (not required).  Instead I
# use Cloudflare's CDN version of mathjax, using the
# (misleading) latest.js to get the latest version (so not
# necessarily 2.7.7).
# See /usr/share/doc/pandoc/README.Debian for a list of
# optional pandoc dependencies you may need.

MATHJAX='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/latest.js?config=TeX-MML-AM_CHTML'
PANDOC_MARKDOWN_BASE="pandoc --to html --mathjax=$MATHJAX"
PANDOC_MARKDOWN_STANDALONE="$PANDOC_MARKDOWN_BASE --standalone"
PANDOC_MARKDOWN_FRAGMENT="$PANDOC_MARKDOWN_BASE"
# MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT --from markdown"
MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT --from gfm"

USAGE="showmd [--format] [--<formatter>] <markdown-file>"
FORMATTERS="formatters: pandoc markdown multi pinline pmulti github"

JUST_FORMAT=false
while [ $# -gt 1 ]
do
    case "$1" in
        --format)
            JUST_FORMAT=true
            shift
            ;;
        --pandoc)
            MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT --from markdown"
            shift
            break
            ;;
        --markdown)
            MARKDOWN=markdown
            shift
            break
            ;;
        --multi)
            MARKDOWN=multimarkdown
            shift
            break
            ;;
        --pinline)
            MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT"
            shift
            break
            ;;
        --pmulti)
            MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT --from markdown_mmd"
            shift
            break
            ;;
        --github)
            MARKDOWN="$PANDOC_MARKDOWN_FRAGMENT --from gfm"
            shift
            break
            ;;
        --gitlab)
            MARKDOWN="gitlab-markup"
            shift
            break
            ;;
        *)
            echo "$USAGE" >&2
            echo "$FORMATTERS" >&2
            exit 1
            ;;
    esac
done
case $# in
    1)
        DOC="$1"
        ;;
    *)
        echo "$USAGE" >&2
        echo "$FORMATTERS" >&2
        exit 1
        ;;
esac

TMP1=/tmp/showmd-$$.md
TMP=/tmp/showmd-$$.html
# I remove ASCII formfeeds from the document before
# processing, because reasons.
sed 's===' "$DOC" >$TMP1
$MARKDOWN $TMP1 >$TMP &&
if $JUST_FORMAT
then
    cat $TMP
else
    # On some browsers, xdg-open is buggy in that it doesn't
    # ensure that the browser has rendered the file before
    # it returns. The sleep is a kludge to give the browser
    # time to work. The sleep time may need to be adjusted
    # for very slow machines or very large files.
    #
    # Also, Google Chrome and derivates sometimes give
    # apparently invalid "broker_posix(43)" error messages when
    # opening the file. I don't know why. I've suppressed
    # these in the obvious way, which is kind of dangerous
    # if something actually fails. But it normally never does.
    xdg-open $TMP 2>/dev/null
    if [ $? -ne 0 ]
    then
        echo "showmd: xdg-open failed" >&2
        exit 1
    else
        sleep 2
    fi
fi
rm -f $TMP1 $TMP

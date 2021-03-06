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
PANDOC_MARKDOWN="pandoc --to html --standalone --mathjax=$MATHJAX --template=$HOME/etc/pandoc/default.html5"
MARKDOWN="$PANDOC_MARKDOWN --from markdown"

USAGE="showmd [--format] [--<formatter>] <markdown-file>"
FORMATTERS="formatters: pandoc markdown multi pmulti github"

JUST_FORMAT=false
PANDOC_TITLE=true
while [ $# -gt 1 ]
do
    case "$1" in
        --format)
            JUST_FORMAT=true
            shift
            ;;
        --pandoc)
            MARKDOWN="$PANDOC_MARKDOWN --from markdown"
            shift
            break
            ;;
        --markdown)
            MARKDOWN=markdown
            PANDOC_TITLE=false
            shift
            break
            ;;
        --multi)
            MARKDOWN=multimarkdown
            PANDOC_TITLE=false
            shift
            break
            ;;
        --pmulti)
            MARKDOWN="$PANDOC_MARKDOWN --from markdown_mmd"
            shift
            break
            ;;
        --github)
            MARKDOWN="$PANDOC_MARKDOWN --from gfm"
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

if $PANDOC_TITLE
then
    # Omit the title header when displaying the HTML, and
    # get a "decent" tab title. Pandoc *really* wants to
    # mess with your document.
    MARKDOWN="$MARKDOWN --metadata title=showmd:$DOC --css=h1.title{display:false;}"
fi

TMP=/tmp/showmd-$$.html
# I remove ASCII formfeeds from the document before
# processing, because reasons.
sed 's===' "$DOC" | $MARKDOWN >$TMP &&
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
    xdg-open "$TMP" 2>/dev/null
    if [ $? -ne 0 ]
    then
        echo "showmd: xdg-open failed" >&2
        exit 1
    else
        sleep 2
    fi
fi
rm -f "$TMP"

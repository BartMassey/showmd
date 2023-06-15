# showmd: command-line browser markdown viewer
Bart Massey

The Bourne shell script `showmd.sh` in this directory will
format a Markdown file and open the resulting HTML in a
browser tab.

This work is the result of many hours of grotty hacking and
researching, so I thought it was worth sharing rather than
"discovering" these things from scratch. It is surprising
how gross it turned out to be to get a good result on this
seemingly-simple task.

## Installing

This project is currently only "tested" and supported on
Debian Linux. Making it work with other Linux distros
shouldn't be too hard. Making it work with MacOS will likely
be harder. I am skeptical about the Windows prospects.

Some Debian packages must/should be installed for this
script to work.

* `xdg-utils` is used to open the browser tab in your
  user-configured browser.

* `pandoc` is not required, but highly desirable: it
   provides the default Markdown formatter as well as
   several other useful ones.

* `markdown` or `multimarkdown` provides a formatter for
  ["Classic" Markdown](https://daringfireball.net/projects/markdown/)
  via the `--multi` option.
  Both packages provide a binary named `markdown`, so you
  cannot have both installed: I don't know the difference
  between them, if any. `pandoc` seems to do fine with
  Classic Markdown though. `pandoc` Classic Markdown is the default for this
  script: you may use `--pandoc` if desired.

* `multimarkdown` provides a formatter for
  ["Classic" MultiMarkdown](https://fletcherpenney.net/multimarkdown/)
  via the `--multi` option, as well as a Classic Markdown
  formatter: see above. `pandoc` seems to do fine with
  Classic MultiMarkdown, though: use `--pmulti` for this.

Once you have your chosen packages installed, copy the
`showmd.sh` script to a bin somewhere and make sure it's
executable: you should then be good to go.

## Usage

Run with

    showmd [--format] [--<formatter>] <markdown-file>

where *formatter* is one of the following:

* `pandoc`: Pandoc Classic Markdown

* `markdown`: Classic Markdown using the Classic Markdown
  formatter.

  The Classic Markdown formatter doesn't handle UTF-8
  properly.  It also doesn't handle LaTeX math at all.

* `multi`: Classic MultiMarkdown using the Classic MultiMarkdown
  formatter.

  The Classic Markdown formatter doesn't handle LaTeX math
  at all. I haven't checked whether it handles UTF-8
  properly: I doubt it.

* `pmulti`: MultiMarkdown using the `pandoc` formatter.

* `github`: Github Markdown using the `pandoc` formatter.

* `gitlab`: Gitlab Markdown using the `gitlab-markup` formatter.

  Using this requires Ruby `gem gitlab-markup`, which
  currently requires manually doing `gem markdown`, which is
  unfortunate. This version also seems buggy relative to
  what's on GitLab, mis-rendering some HTML entities.

## Issues

(See also the project Issue tracker.)

* The `pandoc` formatters handle LaTeX math using
  [MathJax](https://www.mathjax.org/). See the script source
  and its comments for the gory details if you care. There
  is currently no way to turn this off: you will be
  MathJax-enabled even if your HTML doesn't use it. Meh.

* The tab title is a work in progress. For `pandoc`
  formatters the result is not great. For non-`pandoc`
  formatters it's just noise.

* The script currently filters ASCII formfeed characters
  (ASCII FF, confusingly, character code 12 decimal)
  from the Markdown before processing, because reasons.
  I can't imagine anyone caring, but thought I should
  document it for completeness.

* The error reporting from `xdg-open` is kind of a mess. See
  the script source and comments for the details.

## License

This work is made available under the "MIT License". Please
see the file `LICENSE` in this distribution for license
terms.

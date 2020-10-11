#!/usr/bin/env bash

gsed -e 's/&nbsp;/ /g' -i html/*.html
gsed -e '/\s*<link/d' -i html/*.html
gsed -e '/\s*<meta/d' -i html/*.html
gsed -e '/\s*<base/d' -i html/*.html
gsed -e '/<script>/,/<\/script>/d' -i html/*.html
gsed -e '/\s*<script/d' -i html/*.html
gsed -e '/\s*<option/d' -i html/*.html
gsed -e 's!<img.*>!!g' -i html/*.html
gsed -e 's!<h1.*>!!g' -i html/*.html
gsed -e 's!<input.*>!!g' -i html/*.html
gsed -e '/<nav>/,/<\/nav>/d' -i html/*.html
gsed -e '/<div class="l-local-nav pc-only footercoler">/,/^<\/div>/d' -i html/*.html
ls html/*.html | xargs -I{} tidy -q -asxml -m {}

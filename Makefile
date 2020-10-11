.PHONY: fetch result.json

fetch:
	./fetch.sh

result.json: html/*.html
	-./parse.sh
	ls html/*.html | xargs -I {} bash -c 'perl filter.pl {}'

combined.json:
	jq -s 'group_by(.name)|flatten' result/*.json > combined.json
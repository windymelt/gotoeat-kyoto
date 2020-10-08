.PHONY: fetch result.json

fetch:
	./fetch.sh

result.json: html/*.html
	-./parse.sh
	ls html/*.html | xargs -I {} bash -c 'perl filter.pl {}'

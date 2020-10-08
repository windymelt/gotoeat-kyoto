#!/usr/bin/env bash
seq 160 | xargs -I {} curl -o html/{}.html "https://premium-gift.jp/kyoto-eat/use_store?events=page&id={}&store=&addr=&industry="

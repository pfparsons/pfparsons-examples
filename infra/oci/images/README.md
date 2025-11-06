# OCI Image Build

## High Levlel Overview

1. Gather list of images defined


curl -s https://api.github.com/repos/bazelbuild/bazelisk/releases/latest
jq '.tag_name as $tag | ( .assets[] | {name:.name,tag:$tag,url:.browser_download_url}) '

jq '.tag_name as $tag | ( [ .assets[] | {name:.name,tag:$tag,url:.browser_download_url} } ) '


.tag_name as $tag | [ .assets[] | { name:.name, tag:$tag, url:.browser_download_url } ] 

cat br.json | jq -r '.assets[] | select(.name=="bazelisk-linux-amd64") | .browser_download_url'
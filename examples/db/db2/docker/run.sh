#!/bin/bash
this_dir="$(dirname $(realpath $0))"

# db2_version="latest"
# db2_version="11.5.9.8"
db2_version="11.5.8.0"

# repo="icr.io/db2_community"
repo="docker.io/ibmcom"

image_tag="$repo/db2:$db2_version"

data_dir="$this_dir/data/$version"
mkdir -p "$data_dir"

docker run -h db2server --name db2server --restart=always --detach --privileged=true -p 50000:50000 --env-file .env_list -v "$data_dir":/database "$image_tag"

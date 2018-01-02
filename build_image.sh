#!/bin/bash

set -euo pipefail

REPOSITORY="contiv/ovs"
IMAGE=$REPOSITORY:${NETPLUGIN_CONTAINER_TAG:-latest}

function get_image_id() {
    docker inspect --format '{{.ID}}' $IMAGE || :
}

old_image=$(get_image_id)

docker build -t $IMAGE -t $REPOSITORY:latest .

new_image=$(get_image_id)

if [ -n "$old_image" ] && [ "$old_image" != "$new_image" ]; then
    echo Removing old image $old_image
    docker rmi -f $old_image >/dev/null 2>&1 || true
fi

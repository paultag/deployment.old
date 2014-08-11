#!/bin/bash
# Copyright (c) Paul R. Tagliamonte <tag@pault.ag> under the terms
# and conditions of Moxie.

source /etc/docker/moxie.sh


function load {
    docker run --rm \
        --link postgres:postgres \
        -v /srv/docker/moxie:/moxie \
        -e DATABASE_URL=${DATABASE_URL} \
        paultag/moxie \
            moxie-load $@
}


for fp in $(ls /srv/docker/moxie/); do
    load "/moxie/${fp}"
done

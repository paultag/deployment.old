#!/bin/bash
# Copyright (c) Paul R. Tagliamonte <tag@pault.ag> under the terms
# and conditions of Moxie.

ROLE="moxie"
DATABASE="moxie"

source /etc/docker/moxie.sh


function create {
    echo "Creating database using moxie-init"
    docker run --rm \
        --link postgres:postgres \
        -e DATABASE_URL=${DATABASE_URL} \
        paultag/moxie \
            moxie-init
}

function migrate {
    echo "Migrating database against head"
    docker run --rm \
        --link postgres:postgres \
        -e DATABASE_URL=${DATABASE_URL} \
        paultag/moxie \
            alembic upgrade head
}


function psql {
    docker run --rm \
        --link postgres:postgres \
        paultag/postgres \
            psql postgresql://postgres:postgres@postgres/ \
            -q -c "$@"
}

ROLES=$(psql "SELECT rolname FROM pg_roles;" | grep -i ${ROLE})
DATABASES=$(psql "SELECT datname FROM pg_database;" | grep -i ${DATABASE})


if [ "x${ROLES}" = "x" ]; then
    echo "Creating role: ${ROLE}"
    psql "CREATE ROLE ${ROLE} WITH LOGIN PASSWORD '${ROLE}';"
else
    echo "Existing role: ${ROLE}"
fi


if [ "x${DATABASES}" = "x" ]; then
    echo "Creating Database: ${DATABASE}"
    psql "CREATE DATABASE ${DATABASE} OWNER ${ROLE};"
    create
else
    echo "Existing Database: ${DATABASE}"
    migrate
fi

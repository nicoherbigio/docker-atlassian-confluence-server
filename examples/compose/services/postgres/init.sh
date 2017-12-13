#!/bin/bash
set -ex

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" <<-EOSQL
    CREATE USER ${CONFLUENCE_DATABASE_USER} ENCRYPTED PASSWORD '${CONFLUENCE_DATABASE_PASSWORD}';
    CREATE DATABASE ${CONFLUENCE_DATABASE_NAME} ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;
    GRANT ALL PRIVILEGES ON DATABASE ${CONFLUENCE_DATABASE_NAME} TO ${CONFLUENCE_DATABASE_USER};
EOSQL

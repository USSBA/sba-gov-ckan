#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "ckan_default" <<-EOSQL
    CREATE ROLE "datastore_ro" NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD 'datastore';
    CREATE DATABASE "datastore" OWNER "ckan_default" ENCODING 'utf-8';
EOSQL

#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "ckan_default" <<-EOSQL
    CREATE DATABASE ckan_test OWNER "ckan_default" ENCODING 'utf-8';
    CREATE DATABASE datastore_test OWNER "ckan_default" ENCODING 'utf-8';
EOSQL

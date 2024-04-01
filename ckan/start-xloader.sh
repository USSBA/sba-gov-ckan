#!/bin/bash

echo "Starting xloader worker..."

exec ckan -c ckan.ini jobs worker &

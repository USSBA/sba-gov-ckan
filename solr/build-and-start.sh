#!/bin/bash


IMAGE=ckan-solr
docker image build -t ${IMAGE} .
docker container run -it -p 8983:8983 --rm ${IMAGE}


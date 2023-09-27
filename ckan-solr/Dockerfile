## TODO: Once ckan 2.10 is live in production IAS will no longer need to maintain this SOLR image.
## Leaving here for now as a reference in case the team needs to pivot.

FROM ckan/ckan-solr:2.10-solr9
##FROM ubuntu:20.04
#FROM alpine:3.18
##RUN apt-get update -y && apt-get install --no-cache curl bash openjdk8 -y
#RUN apk --update add --no-cache curl bash openjdk8
#ENV SOLR_VERSION=8.9.0
#ENV CKAN_VERSION=2.10.0
#WORKDIR /opt/
#RUN cd /opt \
#  && curl https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz -o solr.tgz \
#  && tar -xvzf solr.tgz \
#  && rm solr.tgz \
#  && mv solr-${SOLR_VERSION}/ solr/
#ADD \
#  https://raw.githubusercontent.com/ckan/ckan/ckan-${CKAN_VERSION}/contrib/docker/solr/solrconfig.xml \
#  https://raw.githubusercontent.com/ckan/ckan/ckan-${CKAN_VERSION}/ckan/config/solr/schema.xml \
#  https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/${SOLR_VERSION}/solr/server/solr/configsets/basic_configs/conf/currency.xml \
#  https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/${SOLR_VERSION}/solr/server/solr/configsets/basic_configs/conf/synonyms.txt \
#  https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/${SOLR_VERSION}/solr/server/solr/configsets/basic_configs/conf/stopwords.txt \
#  https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/${SOLR_VERSION}/solr/server/solr/configsets/basic_configs/conf/protwords.txt \
#  https://raw.githubusercontent.com/apache/lucene-solr/releases/lucene-solr/${SOLR_VERSION}/solr/server/solr/configsets/data_driven_schema_configs/conf/elevate.xml \
#  /opt/solr/server/solr/ckan/conf/
#RUN echo 'name=ckan' > /opt/solr/server/solr/ckan/core.properties
#WORKDIR /opt/solr/
#CMD ["bin/solr", "start", "-f", "-force"]
#

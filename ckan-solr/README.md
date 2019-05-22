# Apache Solr

For more information on Apache Solr, see [Apache Solr's documentation](https://lucene.apache.org/solr/guide/)

## Infrastructure Usage

To support CKAN, we have planned for only a single non-distributed, non-replicated instance of Solr running at a time.  The data directory is hosted on AWS EFS, and mounted to the container at runtime.  For the predicted usage of this system, it is unlikely we will exceed the demands of solr beyond this.  

### Volumes

`/opt/solr/server/solr/ckan/data/` - the data directory for solr.  This should be externally backed up and mounted at container boot.

## Future Considerations

Should the demands of Solr exceed the ability of a single container to service, the system should be migrated to a truly distributed Solr configuration with zookeeper, sharding, and all that fun stuff.

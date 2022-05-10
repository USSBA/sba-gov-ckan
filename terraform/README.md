# Terraform Base

## Workspaces

- `staging`
- `production`

## Modules

### `ckan`

All the services to support data.sba.gov's CKAN implementation.

- Staging/Production environments

## ECS Guide

You can now exec into a running Fargate container with the latest version of AWSCLI.

### Connect to running Fargate container

```
# Configure AWS Credentials, then run...

$ ./service-list.sh
```

### `backup`

Resources to support backing up SBA.gov services

- SBA.gov EFS
  - staging/production
- SBA.gov DynamoDB
  - UrlToNode staging/production
  - UrlToUrlRedirect staging/production

At this time, AWS Backups does not support Aurora RDS, so backups are managed natively within Aurora, plus an external db-dump service

## Directories

### Application Directory

Information regarding files in the applications directory

The terraform files in the applications directory contains the configuration needed to deploy the CKAN application

- ckan.tf: Contains configuration for CKAN web application
- cluster.tf: Contains configuration for the ECS cluster
- dns.tf: Contains configuration for DomainName Service
- locals.tf: Contains global variables for modules
- solr.tf: Contains configuration for the SOLR container
- vpc.tf: Contains VPC configuration for CKAN AWS VPC
- cloudfront.tf: Contains AWS CloudFront config for CKAN
- datapusher.tf: Contains configuration for the datapusher container
- efs.tf: Contains infrastructure configuration for SOLR container
- versions.tf: Contains configuration for Terraform/AWS versions & providers
- service-list.sh: Can be used to remote EXEC into a FARGATE container

### Databases Directory

Information regarding files in the databases directory

- infrastructure-resources.tf: Contains data elements used for infrastructure code
- locals.tf: Conatains global variables for modules
- postgres.tf: Contains Postgress DB configuration
- redis.tf: Contains ElastiCache Redis configuraton
- versions.tf: Contains configuration for Terraform/AWS versions & providers

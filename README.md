# SBA-GOV-CKAN

https://data.sba.gov is the home of open data at the Small Business Administration.  The platform of choice for hosting this data is called CKAN.  Within this repository, you will find a set of Docker image configurations that make up the services required to run CKAN in a containerized cloud environment.

## Infrastructure Components

The CKAN stack is comprised of the following services.

### Docker Services

#### 1. CKAN
[CKAN](./ckan/README.md) is the front-end website with which users will interact.

#### 2. Solr
[Solr](./ckan-solr/README.md) is the engine which allows users to index and search information contained within datasets.

#### 3. DataPusher
[DataPusher](./ckan-datapusher/README.md) is a background worker service that will process data sets and prepare them for searching and discovery.

### Managed Services

#### 1. AWS ElastiCache Redis
A simple session caching mechanism.

#### 2. AWS RDS PostgreSQL
A relational database to persist metadata for a vast number of entities.

### Network Diagram

![Network Diagram](docs/images/ckan-network.png)

## Development

For a more in-depth look at container environment configurations please navigate to the respective sub-directory.

Requirements are:
1. docker
2. docker-compose

### Running locally with `docker-compose`

While CKANs cloud infrastructure uses managed Postgres and Redis, for testing purposes, we have added these services to docker-compose

With docker-compose installed running these containers is easy. Simply run `docker-compose up --build` in your terminal from the root of this repository.

_**Note:** The docker-compose.yaml file in this repository uses the `host` networking mode. As a result when running on Windows or Mac you may need to connect to the virtual machine in which Docker runs rather than your `localhost`._

## Build and Deployment Pipeline

This project is built with CircleCI and has the configuration [in this repository](./.circleci/config.yml).

### Feature Branch

When a new branch (not `master`) is pushed to GitHub, circleci will:

1) Build the docker image
1) Run a [snyk](https://www.snyk.io) scan on the built image

### Master Branch

1) Build the docker image
1) Register the docker image tag with snyk ECR scanning (coming soon!)
1) Push the docker image to AWS ECR (Elastic Container Registry) with these tags:
  * `latest`
  * `<git-hash>` (coming soon)

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

<sub>All contributions are subject to the license and in no way imply compensation for contributions.</sub>


## Code of Conduct
We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Issues

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.

<sub>The agency reserves the right to change this policy at any time.</sub>

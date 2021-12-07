# sba-gov-ckan

https://data.sba.gov is the home of open data at the Small Business Administration.  The platform of choice for hosting this data is called CKAN.  Within this repository, you will find a set of Docker image configurations that make up the services required to run CKAN in a containerized cloud environment.

## Infrastructure Components

Custom Docker Images

* [CKAN](./ckan/README.md)
* [Apache Solr](./ckan-solr/README.md)
* [DataPusher](./ckan-datapusher/README.md)

![Network Diagram](docs/images/ckan-network.png)

## User Management

The purpose of this section is to demonstrate how user accounts can be created, password can be reset, and if necessary promote a user to sysadmin status using the ckan command line utility from a running container. This section assumes that you are using the docker-compose solution provided and that CKAN services are already running on your local machine or that you have a running AWS Fargate service.


### How to gain access to the running container

Please be sure that the present working directory is the root of this project and the following software has been installed and configured.

- docker
- docker-comose
- awscli
- jq

If you are running CKAN using the provided `docker-compose` solution then you can gain shell access to the running container using the following command.

```
$ docker-compose exec ckan /bin/bash
```

If you are running CKAN as a Fargate service in AWS then you can gain shell accesss to the running container considering the service has the [execute-command](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#enable_execute_command) enabled. At the root of this repository we have crafted a shell script named `fargate-service-list.sh` that will generate the `awscli` command necessary for connecting to a running running service task.

Simply run the script which will prompt for some information:

- Choose an ECS Cluster
- Then choose the ECS Service found on that cluster
- Then choose the ECS task running under the provision of that service

It will then generate a command to copy and paste which will look like the following example:

```
  aws ecs execute-command --interactive --cluster production \
    --task 11223344556677889900 --container ckan --command '/bin/bash'
```


### How to use the ckan command line

Display a list of users.

```
$ ckan user list
```

Creating a new user.

```
# with prompt
$ ckan user add 'username'

# without prompt
$ ckan user add 'username' email='email' password='password'
```

Reset a users password.

```
$ ckan user setpass 'username'
```

Remove a user.

```
$ ckan user remove 'username'
```

Display a list of sysadmin users.

```
$ ckan sysadmin list
```

Promote a user to sysadmin.

```
$ ckan sysadmin add 'username'
```

Demote a sysadmin user.

```
$ ckan sysadmin remove 'username'
```


## Local Development

Requirements are:
1. docker installed
2. docker-compose installed

This solution will also require an entry into your `hosts` file of the following `127.0.0.1 sba.ckan.com` and this file can be found respectivly based on your OS at:

* Windows: `c:\windows\system32\drivers\etc\hosts`
* Linux: `/etc/hosts`

```
# In a Linux setting this is easy!
$ sudo echo "127.0.0.1 sba.ckan.com" >> /etc/hosts
```

**Note:**

To explain why this is necessary please understand that in a production setting the `CKAN_SITE_URL` variable must be able to resolve.  When a dataset is uploaded, CKAN tracks that file in **Solr** as a fully qualified URI which triggers a **DataPusher** job to process that file.  If the URI cannot resolve then the **DataPusher** job will fail and the `preview` option of that dataset in the browser will be unavailable.

This docker-compose solution uses a custom `bridge` network where each service is assigned a static IPv4 address.  This way we can use the `extra_hosts` option of the **DataPusher** service to map `sba.ckan.com` to the static IPv4 address assigned to **CKAN** allowing it to resolve both on your local machine and by the **DataPusher** virtual machine.


### Using docker-compose to run the solution locally

* Open a command line shell
* Run `docker-compose build` to build all images in the solution
* Run `docker-compose up` once the images have been built
* Wait for services to come online, and the databases to be initialized
* Interface with the following service via a web browser:
  * CKAN @ [http://sba.ckan.com](http://sba.ckan.com)
  * FakeEmail @ [http://sba.ckan.com:1080](http://sba.ckan.com:1080)
  * Solr @ [http://sba.ckan.com:8983](http://sba.ckan.com:8983)
* Open another command line shell
* Run `docker-compose -f docker-compose.sysadmin.yaml run --rm sysadmin` to create the ckanadmin user
* Login to CKAN using `ckanadmin` as both the username and password
* Login to FakeEmail using `fake` as both the username and passowrd
* Enjoy!

### Using docker-compose to stop and cleanup locally

* Open a command line shell
* Run:
  * `docker-compose down` to remove all contaienrs and networks
  * `docker-compose down -v` to remove all containers, volumes, and networks
  * `docker-compose down -v --rmi all` to remove all containers, volumes, and networks and images

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

# SBA-GOV-CKAN

TODO: describe this project and it's purpose. 

## Contributing

TODO: describe the constraints and process in which the opensource community may contribute to this project.


## Running Containers

For a more in-depth look at container environment configurations please navigate to the respective sub-directory.

### docker-compose

With docker-compose installed running these containers is easy. Simply run `docker-compose up` in your terminal from the root of this repository.

_**Note:** The docker-compose.yaml file in this repository uses the `host` networking mode. As a result when running on Windows or Mac you may need to connect to the virtual machine in which Docker runs rather than your `localhost`._

### The CKAN Stack

The CKAN stack is comprised of the following five services. 

#### 1. CKAN
The front-end website in which users will interact with.

#### 2. Solr
The engine which allows users to index and search information contained within data sets.

#### 3. DataPusher
A background worker service that will process dat sets and prepare them for searching and discovery.

#### 4. Redis
A simple caching mechanism.

#### 5. PostgreSQL
A relational database to persist metadata for a vast number of entities.



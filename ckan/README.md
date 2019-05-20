## CKAN

### Volumes

#### /var/lib/ckan/
The default location where CKAN file uploads will be persisted. In a production environment this volume should point NAS device so that it can be shared across any number of CKAN containers.

#### /root/.aws/
This volume is not intended for production environments. If you are not running on the AWS cloud platform please refer to the [Environment](#Environment) section of this document.


### Environment

In addition to the following environment variables any [AWS Command Line](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) environment variable can be passed into the container.

_**Note:** The AWS IAM policy and role may very between environments, much less accounts, so you will need to configure this policy respectively._



* **CKAN**
  * [APP_UUID](#APP_UUID)
  * [APP_UUID_PSID](#APP_UUID_PSID)
  * [CKAN_PORT](#CKAN_PORT)
  * [CKAN_SITE_URL](#CKAN_SITE_URL)
  * [SESSION_SECRET](#SESSION_SECRET)
  * [SESSION_SECRET_PSID](#SESSION_SECRET_PSID)
* **POSTGRESQL**
  * [POSTGRES_DB](#POSTGRES_DB)
  * [POSTGRES_FQDN](#POSTGRES_FQDN)
  * [POSTGRES_PASSWORD](#POSTGRES_PASSWORD)
  * [POSTGRES_PASSWORD_PSID](#POSTGRES_PASSWORD_PSID)
* **DATAPUSHER & DATASTORE**
  * [DATASTORE_DB](#DATASTORE_DB)
  * [DATASTORE_ROLENAME](#DATASTORE_ROLENAME)
  * [DATAPUSHER_FQDN](#DATAPUSHER_FQDN)
  * [DATAPUSHER_HTTP_SCHEME](#DATAPUSHER_HTTP_SCHEME)
  * [DATAPUSHER_PORT](#DATAPUSHER_PORT)
* **REDIS**
  * [REDIS_PORT](#REDIS_PORT)
  * [REDIS_DBID](#REDIS_DBID)
  * [REDIS_FQDN](#REDIS_FQDN)
* **SOLR**
  * [SOLR_PORT](#SOLR_PORT)
  * [SOLR_CORE_NAME](#SOLR_CORE_NAME)
  * [SOLR_HTTP_SCHEME](#SOLR_HTTP_SCHEME)
  * [SOLR_FQDN](#SOLR_FQDN)
  * [CKAN_SITE_ID](#CKAN_SITE_ID)
* **SMTP**
  * [SMTP_FQDN](#SMTP_FQDN)
  * [SMTP_PORT](#SMTP_PORT)
  * [CKAN_SMTP_STARTTLS](#CKAN_SMTP_STARTTLS)
  * [CKAN_SMTP_USER](#CKAN_SMTP_USER)
  * [CKAN_SMTP_USER_SMID](#CKAN_SMTP_USER_SMID)
  * [CKAN_SMTP_PASSWORD](#CKAN_SMTP_PASSWORD)
  * [CKAN_SMTP_PASSWORD_SMID](#CKAN_SMTP_PASSWORD_SMID)
  * [CKAN_SMTP_MAIL_TO](#CKAN_SMTP_MAIL_TO)
  * [CKAN_SMTP_MAIL_FROM](#CKAN_SMTP_MAIL_FROM)


#### APP_UUID
A [universally unique identifier](https://en.wikipedia.org/wiki/Universally_unique_identifier) of the CKAN configuration file in canonical textual representation. Alternatively `APP_UUID_PSID` can be used instead. If `APP_UUID` is configured then `APP_UUID_PSID` will be ignored.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### APP_UUID_PSID
An AWS Systems Manager Parameter Store key that will be fetched from AWS at runtime and it's value assigned to the `APP_UUID` environment variable.

_Required: Yes, Optional_

[_return to index_](#Runtime Environment Variables)


#### CKAN_PORT
The traffic port in which CKAN will bind to.

_**Required:** No, **Default:** 80_

[_return to index_](#Environment)


#### CKAN_SITE_URL
The absolute URL of your CKAN website. There are many features of CKAN that make use of this absolute URL for them to function correctly.

_**Required:** Yes_

[_return to index_](#Environment)


#### SESSION_SECRET
An alpha-numeric string of 25 characters that will enable sessions to be maintained across any number of containers. Alternatively the `SESSION_SECRET_PSID` variable can be configured instead. If a `SESSION_SECRET` is used then `SESSION_SECRET_PSID` will be ignored.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### SESSION_SECRET_PSID
An AWS Systems Manager Parameter Store key that will be fetched from AWS at runtime and it's value assigned to the `SESSION_SECRET` environment variable.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### POSTGRES_DB
The name of the primary CKAN database.

_**Required:** No, **Default:** ckan_default_

[_return to index_](#Environment)


#### POSTGRES_USER
The user/role name used to make both read and write connections to primary database.

_**Required:** No, **Default:** ckan_default_

[_return to index_](#Environment)


#### POSTGRES_PORT
The port number of your PSQL server.

_**Required:** No, **Default:** 5432_

[_return to index_](#Environment)


#### POSTGRES_FQDN
The full DNS name or IP address of your PSQL server.

_**Required:** Yes_

[_return to index_](#Environment)


#### POSTGRES_PASSWORD
The password used by the `POSTGRES_USER` to establish connections to your PSQL server. Alternatively `POSTGRES_PASSWORD_PSID` can be configured instead. If this variable is configured then `POSTGRES_PASSWORD_PSID` will be ignored completely.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### POSTGRES_PASSWORD_PSID
An AWS Systems Manager Parameter Store key that will be fetched from AWS at runtime and it's value assigned to the `POSTGRES_PASSWORD` environment variable.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### DATASTORE_DB
The name of the datastore database.

_**Required:** No, **Default:** datastore_default_

[_return to index_](#Environment)


#### DATASTORE_ROLENAME
The user or role name used to make read-only connections to the `DATASTORE_DB` database.

_**Required:** No, **Default:** datastore_default_

[_return to index_](#Environment)


#### DATAPUSHER_PORT
The port number used to make connections to the DataPusher endpoint.

_**Required:** No, **Default:** 8800_

[_return to index_](#Environment)


#### DATAPUSHER_HTTP_SCHEME
The URL scheme used to make connections to your DataPusher endpoint. (eg. `http` or `https`)

_**Required:** No, **Default:** http_

[_return to index_](#Environment)


#### DATAPUSHER_FQDN
The full DNS name or IP address of your DataPusher endpoint.

_**Required:** Yes_

[_return to index_](#Environment)


#### REDIS_PORT
The port number used to make connections to your Redis server.

_**Required:** No, **Default:** 6379_

[_return to index_](#Environment)


#### REDIS_DBID
The CKAN database identifier.

_**Required:** No, **Default:** 1_

[_return to index_](#Environment)


#### REDIS_FQDN
The full DNS name or IP address of your Redis server.

_**Required:** Yes_

[_return to index_](#Environment)


#### SOLR_PORT
The port number used to make connections to your Solr endpoint.

_**Required:** No, **Default:** 8983_

[_return to index_](#Environment)


#### SOLR_CORE_NAME
The CKAN Solr core name.

_**Required:** No, **Default:** ckan_

[_return to index_](#Environment)


#### SOLR_HTTP_SCHEME
The URL scheme used to make connections to your Solr endpoint. (eg. http or https)

_**Required:** No, **Default:** http_

[_return to index_](#Environment)


#### SOLR_FQDN
The full DNS name or IP address of your Solr server.

_**Required:** Yes_

[_return to index_](#Environment)


#### CKAN_SITE_ID
A unique name for your CKAN site used by Solr for search indexing. If multiple CKAN sites are pointing at the same Solr database and core then a unique ID will need to be issued by each site.

_**Required:** No, **Default:** default_

[_return to index_](#Environment)


#### SMTP_FQDN
The full DNS name or IP address of your SMTP endpoint.

_**Required:** No, **Default:** email-smtp.us-east-1.amazonaws.com_

[_return to index_](#Environment)


#### SMTP_PORT
The port number used to make connections to your SMTP endpoint.

_**Required:** No, **Default:** 587_

[_return to index_](#Environment)


#### CKAN_SMTP_STARTTLS
Weather or not TLS connections can be established to the SMTP endpoint. 

_**Required:** No, **Default:** True_

[_return to index_](#Environment)


#### CKAN_SMTP_USER
The user name necessary to establish secure connections to the SMTP endpoint. Alternatively `CKAN_SMTP_USER_SMID` can be configured. If this value is configured then `CKAN_SMTP_USER_SMID` will be ignored completely.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### CKAN_SMTP_USER_SMID
An AWS Secrets Manager key that will be fetched from AWS at runtime and it's value assigned to the `CKAN_SMTP_USER` environment variable.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### CKAN_SMTP_PASSWORD
The password necessary to establish secure connections to the SMTP endpoint. Alternatively `CKAN_SMTP_PASSWORD_SMID` can be configured. If this value is configured then `CKAN_SMTP_PASSWORD_SMID` will be ignored completely.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### CKAN_SMTP_PASSWORD_SMID
An AWS Secrets Manager key that will be fetched from AWS at runtime and it's value assigned to the `CKAN_SMTP_PASSWORD` environment variable.

_**Required:** Yes, Optional_

[_return to index_](#Environment)


#### CKAN_SMTP_MAIL_TO
An email address where CKAN generated mail notifications will be directed.

_**Required:** Yes_

[_return to index_](#Environment)


#### CKAN_SMTP_MAIL_FROM
An email address where CKAN generated mail will originate from.

_**Required:** Yes_

[_return to index_](#Environment)
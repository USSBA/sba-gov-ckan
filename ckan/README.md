# CKAN

## Volumes

`/var/lib/ckan/`

The default location where CKAN file uploads will be persisted. In a production environment this volume should point NAS device so that it can be shared across any number of CKAN containers.

`/root/.aws/`

For testing with docker-compose, we default to mounting "~/.aws" from the local user.  This volume is not intended for production environments. If you are not running on the AWS cloud platform please refer to the [Environment](#Environment) section of this document.

## Environment

In addition to the following environment variables any [AWS Command Line](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) environment variable can be passed into the container.

**Note:**

The AWS IAM policy and role may very between environments, much less accounts, so you will need to configure this policy respectively.

* **CKAN**
  * [APP_UUID](#APP_UUID)
  * [CKAN_PORT](#CKAN_PORT)
  * [CKAN_SITE_URL](#CKAN_SITE_URL)
  * [SESSION_SECRET](#SESSION_SECRET)
  * [CKAN_API_TOKEN_SECRET](#CKAN_API_TOKEN_SECRET)
* **POSTGRESQL**
  * [POSTGRES_DB](#POSTGRES_DB)
  * [POSTGRES_FQDN](#POSTGRES_FQDN)
  * [POSTGRES_PASSWORD](#POSTGRES_PASSWORD)
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
  * [CKAN_SMTP_PASSWORD](#CKAN_SMTP_PASSWORD)
  * [CKAN_SMTP_ERROR_MAIL_TO](#CKAN_SMTP_ERROR_MAIL_TO)
  * [CKAN_SMTP_ERROR_MAIL_FROM](#CKAN_SMTP_ERROR_MAIL_FROM)
  * [CKAN_SMTP_MAIL_FROM](#CKAN_SMTP_MAIL_FROM)
* **GOOGLE_ANALYTICS**
  * [CKAN_GOOGLE_ANALYTICS_ID](#CKAN_GOOGLE_ANALYTICS_ID)

### APP_UUID

A unique identifier for each CKAN purpose built applicaiton depoloyment.

* **Required:** Yes
* **Format:** [Aa-Zz0-9]{8}-[Aa-Zz0-9]{4}-[Aa-Zz0-9]{4}-[Aa-Zz0-9]{4}-[Aa-Zz0-9]{12}
* **Example:** AAAAAAAA-0000-1111-2222-BBBBBBBBBBBB

### CKAN_SITE_ID

A unique name for each CKAN purpose built application deployment.

* **Required:** No
* **Default:** default

### CKAN_PORT

The traffic port in which CKAN will bind to send and recieve requests.

* **Required:** No
* **Default:** 80

### CKAN_SITE_URL

The absolute URL of your CKAN website. There are many features of CKAN that make use of this absolute URL for them to function correctly.

* **Required:** Yes

### SESSION_SECRET

An alpha-numeric string of 25 characters that will enable sessions to be maintained across any number of containers.

* **Required:** Yes

### CKAN_API_TOKEN_SECRET

A secret key which is used to encode and decode API tokens.

* **Required:** Yes
* **Format:** [Aa-Zz0-9]{11}_-[Aa-Zz0-9]{11}
* **Example:** 9OzsqKgYG4o_-6RGZ14ebdsh6

### POSTGRES_DB

The name of the primary CKAN database catalog.

* **Required:** No
* **Default:** ckan_default

### POSTGRES_USER

The user/role name used to make both read and write connections to primary database.

* **Required:** No
* **Default:** ckan_default

### POSTGRES_PASSWORD

The postgress database password.

* **Required:** Yes

### POSTGRES_PORT

The port number of your PSQL server.

* **Required:** No
* **Default:** 5432

### POSTGRES_FQDN

The full DNS name or IP address of your PSQL server.

* **Required:** Yes
* **Example:** postgres.ckan.com

### DATASTORE_DB

The name of the datastore database.

* **Required:** No
* **Default:** datastore_default

### DATASTORE_ROLENAME

The user/role name used to make read-only connections to the datastore database.

* **Required:** No
* **Default:** datastore_default

### DATAPUSHER_PORT

The port number used to make connections to the DataPusher endpoint.

* **Required:** No
* **Default:** 8800

### DATAPUSHER_HTTP_SCHEME

The URL scheme used to make connections to your DataPusher endpoint. (eg. `http` or `https`)

* **Required:** No
* **Default:** http

### DATAPUSHER_FQDN

The full DNS name or IP address of your DataPusher endpoint.

* **Required:** Yes
* **Example:** datapusher.ckan.com

### REDIS_PORT

The port number used to make connections to your Redis server.

* **Required:** No
* **Default:** 6379

### REDIS_DBID

A integer for the CKAN applicaiton and should be unique for each purpose built CKAN deployment. It must be unique when pointing multiple CKAN deployments at a single Redis endpoint.

* **Required:** No
* **Default:** 1

### REDIS_FQDN

The full DNS name or IP address of your Redis server.

* **Required:** Yes
* **Example:** redis.ckan.com

### SOLR_PORT

The port number used to make connections to your Solr endpoint.

* **Required:** No
* **Default:** 8983

### SOLR_CORE_NAME

A string representing the CKAN application Solr core name.

* **Required:** No
* **Default:** ckan

### SOLR_HTTP_SCHEME

The URL scheme used to make connections to your Solr endpoint. (eg. http or https)

* **Required:** No
* **Default:** http

### SOLR_FQDN

The full DNS name or IP address of your Solr server.

* **Required:** Yes
* **Example:** solr.ckan.com

### SMTP_FQDN

The full DNS name or IP address of your SMTP endpoint.

* **Required:** No
* **Default:** email-smtp.us-east-1.amazonaws.com

### SMTP_PORT

The port number used to make connections to your SMTP endpoint.

* **Required:** No
* **Default:** 587

### CKAN_SMTP_STARTTLS

Whether or not TLS connections can be established to the SMTP endpoint.

* **Required:** No
* **Default:** True

### CKAN_SMTP_USER

The user name necessary to establish secure connections to the SMTP endpoint.

* **Required:** Yes

### CKAN_SMTP_PASSWORD

The password necessary to establish secure connections to the SMTP endpoint.

* **Required:** Yes

### CKAN_SMTP_ERROR_MAIL_TO

An email address where CKAN will deliver application error messages.

* **Required:** Conditional
* **Condition:** Required if the `CKAN_SMTP_ERROR_MAIL_FROM` environment variable is used.

### CKAN SMTP_ERROR_MAIL_FROM

An email address that CKAN will use in the `from` line to deliver application error messages.

* **Required:** Optional
* **Condition:** Required if the `CKAN_SMTP_ERROR_MAIL_TO` environment variable is used.

### CKAN_SMTP_MAIL_FROM

An email address where CKAN generated mail will originate from.

* **Required:** Yes

### CKAN_GOOGLE_ANALYTICS_ID

A google analytics ID to provide for all pages.

* **Required:** No

### BYPASS_INIT

An indicator to skip the database initialization processes during container startup. Set this value to `1` to bypass database initialization sequence.

* **Required:** No
* **Default:** 0
import uuid

DEBUG = False
TESTING = False
SECRET_KEY = str(uuid.uuid4())
USERNAME = str(uuid.uuid4())
PASSWORD = str(uuid.uuid4())

NAME = 'datapusher'

# database

SQLALCHEMY_DATABASE_URI = 'sqlite:////tmp/job_store.db'

# webserver host and port

HOST = '0.0.0.0'
PORT = ${DATAPUSHER_PORT}

# logging

## NOTE:
## These variables were commented out by default with the source code.
## Leaving them comments out in the case we should ever need them.

# FROM_EMAIL = 'server-error@example.com'
# ADMINS = ['yourname@example.com']  # where to send emails
# LOG_FILE = '/tmp/ckan_service.log'
# SSL_VERIFY = False

STDERR = True
STDOUT = True
MAX_CONTENT_LENGTH = 3221225472

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

HOST = '${DATAPUSHER_FQDN}'
PORT = ${DATAPUSHER_PORT}

# logging

# FROM_EMAIL = 'server-error@example.com'
# ADMINS = ['yourname@example.com']  # where to send emails

# LOG_FILE = '/tmp/ckan_service.log'
STDERR = True
STDOUT = True
# SSL_VERIFY = False
MAX_CONTENT_LENGTH = 73400320

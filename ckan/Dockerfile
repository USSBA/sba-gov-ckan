FROM ckan/ckan-base:2.10.1

RUN apk update

COPY requirements.txt .

COPY start-xloader.sh /docker-entrypoint.d/

COPY ckan.ini /srv/app/ckan.ini

RUN pip install -r requirements.txt

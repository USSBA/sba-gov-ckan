#FROM ckan/ckan-base:2.10.1
FROM openknowledge/ckan-dev:2.10.1

RUN apk update

COPY requirements.txt .

RUN pip install -r requirements.txt

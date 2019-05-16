FROM debian:jessie

# install dependencies
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        python-dev \
        python-pip \
        python-virtualenv \
        python-wheel \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        build-essential \
        git-core \
        vim \
        wget \
        gettext-base \
        netcat \
    && apt-get -q clean \
    && pip install awscli \
    && rm -rf /var/lib/apt/lists/*

# ckan install environment
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan

# ckan user account
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# configure ckan virtual environment
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH \
    && virtualenv $CKAN_VENV \
    && ln -s $CKAN_VENV/bin/pip /usr/local/bin/ckan-pip \
    && ln -s $CKAN_VENV/bin/paster /usr/local/bin/ckan-paster

# pull the ckan source code
RUN git clone --progress https://github.com/ckan/ckan.git $CKAN_VENV/src/ckan \
    && cd $CKAN_VENV/src/ckan/ \
    && git checkout tags/ckan-2.8.2 \
    && rm -rf .git .github

# install ckan
RUN ckan-pip install -U pip \
    && ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt \
    && ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt \
    && ckan-pip install -e $CKAN_VENV/src/ckan/ \
    && ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini \
    && chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

# install pages plugin
RUN ckan-pip install -e 'git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages'

# customize container entrypoint that will configure the application
COPY ckan-entrypoint.sh /ckan-entrypoint.sh
COPY production.ini $CKAN_CONFIG/production.ini.unconfigured
RUN chmod +x /ckan-entrypoint.sh

ENTRYPOINT ["/ckan-entrypoint.sh"]
CMD ["ckan-paster","serve","/etc/ckan/production.ini"]

FROM ubuntu:16.04

ENV DATAPUSHER_HOME /usr/lib/ckan/datapusher

# install dependencies
RUN apt-get update \
    && apt-get -y install \
        python-dev \
        python-pip \
        python-virtualenv \
        build-essential \
        libxslt1-dev \
        libxml2-dev \
        zlib1g-dev \
        git \
        gettext-base \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -U pip

# create home directory of datapusher
RUN mkdir -p $DATAPUSHER_HOME/src

# set working directory
WORKDIR $DATAPUSHER_HOME/src

# clone the datapusher repository
RUN git clone -b '0.0.10' https://github.com/ckan/datapusher.git

# install pip
#RUN apt-get install -y python-pip && \
#apt-get autoremove -y && \
#pip install -U pip

# install datapusher and it's dependencies
WORKDIR $DATAPUSHER_HOME/src/datapusher
#COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt && pip install -e .

# entrypoint configuration
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY datapusher_settings.py $DATAPUSHER_HOME/src/datapusher/deployment/datapusher_settings.py.unconfigured
RUN chmod 700 /docker-entrypoint.sh

# configure and run the datapusher service
EXPOSE 8800
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "python", "datapusher/main.py", "deployment/datapusher_settings.py"]

FROM ubuntu:20.04

ENV DATAPUSHER_HOME /usr/lib/ckan/datapusher

# install dependencies
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update \
    && apt-get -y install \
        python3-dev \
        python3-pip \
        build-essential \
        libxslt1-dev \
        libxml2-dev \
        zlib1g-dev \
        git \
        gettext-base \
        locales-all \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && python --version
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && pip --version

# create home directory of datapusher
RUN mkdir -p $DATAPUSHER_HOME/src

# set working directory
WORKDIR $DATAPUSHER_HOME/src

# clone the datapusher repository
RUN git clone -b '0.0.17' https://github.com/ckan/datapusher.git

# install datapusher and it's dependencies
WORKDIR $DATAPUSHER_HOME/src/datapusher

# bump requests package to latest version to work around an issue
RUN sed -i -E 's/(requests\[security\])==.*/\1==2.25.1/' requirements.txt
RUN pip install -r requirements.txt && pip install -e .

# entrypoint configuration
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY datapusher_settings.py $DATAPUSHER_HOME/src/datapusher/deployment/datapusher_settings.py.unconfigured
RUN chmod 700 /docker-entrypoint.sh

# configure and run the datapusher service
EXPOSE 8800
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "python", "datapusher/main.py", "deployment/datapusher_settings.py"]

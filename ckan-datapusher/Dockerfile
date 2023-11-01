FROM openknowledge/datapusher


EXPOSE 8800

#FROM ubuntu:jammy
#
## Set timezone
#ENV TZ=UTC
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#
#
## Set Locale
#ENV LC_ALL=en_US.UTF-8
#
#ENV SRC_DIR=/srv/app/src
#ENV VENV=/usr/lib/ckan/dpplus_venv
#ENV CFG_DIR=/etc/ckan/datapusher
#
#WORKDIR ${SRC_DIR}
#
## Set the locale
#RUN apt-get update
#RUN apt-get install --no-install-recommends -y locales
#RUN sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen
#RUN dpkg-reconfigure --frontend=noninteractive locales
#RUN update-locale LANG=${LC_ALL}
#
## Instal apt-utils
#RUN apt-get install --no-install-recommends -y \
#   apt-utils \
#   python3-venv \
#   python3-dev \
#   python3 \
#   build-essential \
#   libxslt1-dev \
#   libxml2-dev \
#   libffi-dev \
#   wget \
#   curl \
#   unzip \
#   python3-pip \
#   git\
#   libpq-dev\
#   file
#
##install qsv;
#RUN wget https://github.com/jqnatividad/qsv/releases/download/0.108.0/qsv-0.108.0-x86_64-unknown-linux-gnu.zip
#RUN unzip qsv-0.108.0-x86_64-unknown-linux-gnu.zip
#RUN rm qsv-0.108.0-x86_64-unknown-linux-gnu.zip
#RUN mv qsv* /usr/local/bin
#
##python env setup; link python3 to python cmd; make venv; install uwsgi;
#RUN ln -s /usr/bin/python3 /usr/bin/python
#RUN python -m venv ${VENV}
#RUN ${VENV}/bin/pip install uwsgi
#
##install tests 
##Add custom values before installing tests https://github.com/dathere/testing-datapusher-plus.git
##and unable the script in startup.sh
##RUN git clone --branch master https://github.com/dathere/testing-datapusher-plus.git
##RUN ${VENV}/bin/pip install -r testing-datapusher-plus/requirements.txt
##RUN cd ..
#
##INSTALL DATAPUSHER-PLUS FROM SOURCE REPO
#RUN git clone --branch 0.15.0 https://github.com/datHere/datapusher-plus
#RUN cd ${SRC_DIR}/datapusher-plus && \
#   ${VENV}/bin/pip install -r requirements-dev.txt && \
#   ${VENV}/bin/pip install -e .
#
#
##SETUP CONFIG/SETTINGS.PY
#RUN mkdir -p ${CFG_DIR}
#COPY ./example.env ${CFG_DIR}/.env
#ENV JOB_CONFIG=${CFG_DIR}/.env
#
#RUN curl https://raw.githubusercontent.com/dathere/datapusher-plus/0.15.0/deployment/datapusher-uwsgi.ini -o ${CFG_DIR}/uwsgi.ini
#
#COPY startup.sh /startup.sh
#RUN chmod +x /startup.sh
#
#ENTRYPOINT [ "bash", "-c", "/startup.sh" ]
#
#EXPOSE 8800

#FROM ubuntu:20.04
#
#ENV DATAPUSHER_HOME /usr/lib/ckan/datapusher
#
## install dependencies
#ENV TZ=Etc/UTC
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN apt-get update \
#    && apt-get -y install \
#        python3-dev \
#        python3-pip \
#        build-essential \
#        libxslt1-dev \
#        libxml2-dev \
#        zlib1g-dev \
#        git \
#        gettext-base \
#        locales-all \
#    && apt-get -y autoremove \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/*
#
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && python --version
#RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && pip --version
#
## create home directory of datapusher
#RUN mkdir -p $DATAPUSHER_HOME/src
#
## set working directory
#WORKDIR $DATAPUSHER_HOME/src
#
## clone the datapusher repository
## this was 0.0.17, which, is no longer loading certain python modules.
#RUN git clone -b '0.0.18' https://github.com/ckan/datapusher.git
#
## install datapusher and it's dependencies
#WORKDIR $DATAPUSHER_HOME/src/datapusher
#
## bump requests package to latest version to work around an issue
#RUN sed -i -E 's/(requests\[security\])==.*/\1==2.25.1/' requirements.txt
#RUN pip install -r requirements.txt && pip install -e .
#
## entrypoint configuration
#COPY docker-entrypoint.sh /docker-entrypoint.sh
#COPY datapusher_settings.py $DATAPUSHER_HOME/src/datapusher/deployment/datapusher_settings.py.unconfigured
#RUN chmod 700 /docker-entrypoint.sh
#
## configure and run the datapusher service
#EXPOSE 8800
#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD [ "python", "datapusher/main.py", "deployment/datapusher_settings.py"]

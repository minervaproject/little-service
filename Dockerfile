FROM python:2
RUN mkdir /server
WORKDIR /server
ADD requirements.in /server
RUN apt-get update && \
    apt-get -y install mysql-client vim

# HACK (CG)
# I had trouble setting up a multi-container Docker instance within AWS EBS/VPC,
# so this tries to get Redis running in our one container.
# Loosely based on https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04
RUN groupadd -r redis && useradd -r -g redis redis
RUN apt-get -y install build-essential tcl
RUN /bin/bash -c 'curl -O http://download.redis.io/redis-stable.tar.gz && \
	tar xzvf redis-stable.tar.gz && \
	cd redis-stable && make && make install'

RUN /bin/bash -c 'virtualenv /venv  && \
    source /venv/bin/activate  && \
    echo "Installing dependencies..."  && \
    pip install pip-tools  && \
    pip-compile --output-file requirements.txt requirements.in && \
    pip-sync requirements.txt'

ADD .bashrc /root/.bashrc

EXPOSE 80

ADD . /server
ENTRYPOINT ["./docker-entrypoint.sh"]

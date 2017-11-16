FROM python:2
RUN mkdir /server
WORKDIR /server
ADD requirements.in /server
RUN /bin/bash -c 'virtualenv /venv  && \
    source /venv/bin/activate  && \
    echo "Installing dependencies..."  && \
    pip install pip-tools  && \
    pip-compile --output-file requirements.txt requirements.in && \
    pip-sync requirements.txt'

EXPOSE 80

ADD . /server
ENTRYPOINT ["./docker-entrypoint.sh"]

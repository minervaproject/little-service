FROM python:2
RUN mkdir /little_service
WORKDIR /little_service
ADD requirements.in /little_service
RUN /bin/bash -c 'virtualenv /venv  && \
    source /venv/bin/activate  && \
    echo "Installing dependencies..."  && \
    pip install pip-tools  && \
    pip-compile --output-file requirements.txt requirements.in && \
    pip-sync requirements.txt'

EXPOSE 80

ADD . /little_service
ENTRYPOINT ["./docker-entrypoint.sh"]

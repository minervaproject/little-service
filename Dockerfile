FROM python:2
RUN mkdir /scheduler
WORKDIR /scheduler
ADD requirements.in /scheduler
RUN /bin/bash -c 'virtualenv /venv  && \
    source /venv/bin/activate  && \
    echo "Installing dependencies..."  && \
    pip install pip-tools  && \
    pip-compile --output-file requirements.txt requirements.in && \
    pip-sync requirements.txt'

EXPOSE 80

ADD . /scheduler
ENTRYPOINT ["./docker-entrypoint.sh"]

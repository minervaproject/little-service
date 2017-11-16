#!/bin/bash

source /venv/bin/activate

echo -e "Calling DJANGO_SETTINGS_MODULE=config.environments.local python server/manage.py makemigrations ..."
DJANGO_SETTINGS_MODULE=config.environments.ebs python server/manage.py makemigrations

echo -e "Calling DJANGO_SETTINGS_MODULE=config.environments.local python server/manage.py migrate ..."
DJANGO_SETTINGS_MODULE=config.environments.ebs python server/manage.py migrate

# echo -e "Starting Celery ..."
# cd server; celery -A server worker -l info &
# cd ..

echo -e "Calling DJANGO_SETTINGS_MODULE=config.environments.local python server/manage.py runserver 0:80 ..."
DJANGO_SETTINGS_MODULE=config.environments.ebs python server/manage.py runserver 0:80

# bash


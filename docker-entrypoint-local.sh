#!/bin/bash

source /venv/bin/activate

echo -e "Calling DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py makemigrations ..."
DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py makemigrations

echo -e "Calling DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py migrate ..."
DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py migrate

echo -e "Starting Celery ..."
cd little_service; celery -A little_service_app worker -l info &
cd ..

echo -e "Calling DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py runserver 0:80 ..."
DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py runserver 0:80

# DJANGO_SETTINGS_MODULE=little_service.environments.local python little_service/manage.py shell_plus

# bash

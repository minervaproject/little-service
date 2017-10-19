#!/bin/bash

# echo "hi"

source /venv/bin/activate

echo -e "Calling DJANGO_SETTINGS_MODULE=scheduler_service.environments.local python scheduler_service/manage.py makemigrations ..."
DJANGO_SETTINGS_MODULE=scheduler_service.environments.ebs python scheduler_service/manage.py makemigrations

echo -e "Calling DJANGO_SETTINGS_MODULE=scheduler_service.environments.local python scheduler_service/manage.py migrate ..."
DJANGO_SETTINGS_MODULE=scheduler_service.environments.ebs python scheduler_service/manage.py migrate

# echo -e "Starting Celery ..."
# cd scheduler_service; celery -A scheduler worker -l info &
# cd ..

echo -e "Calling DJANGO_SETTINGS_MODULE=scheduler_service.environments.local python scheduler_service/manage.py runserver 0:80 ..."
DJANGO_SETTINGS_MODULE=scheduler_service.environments.ebs python scheduler_service/manage.py runserver 0:80

# bash


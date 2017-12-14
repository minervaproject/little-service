#!/bin/bash
set -e

echo "------------------------------------------------------------------------"
echo
echo "Activating virtual environment with source /venv/bin/activate"
source /venv/bin/activate
echo

echo "------------------------------------------------------------------------"
echo
echo "Exporting environment variable DJANGO_SETTINGS_MODULE=config.environments.local"
export DJANGO_SETTINGS_MODULE=config.environments.ebs
echo

echo "------------------------------------------------------------------------"
echo
echo "Making migrations with python server/manage.py makemigrations"
python server/manage.py makemigrations
echo

echo "------------------------------------------------------------------------"
echo
echo "Applying migrations with python server/manage.py migrate"
python server/manage.py migrate
echo

echo "------------------------------------------------------------------------"
echo
echo "Starting Redis:"
redis-server &
echo
echo "Starting Celery:"
cd server
celery -A service worker -l info &
cd ..
echo

echo "------------------------------------------------------------------------"
echo
echo "Starting web server with python server/manage.py runserver 0:80"
python server/manage.py runserver 0:80
echo

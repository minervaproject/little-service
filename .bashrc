echo
echo "Activating virtual environment with source /venv/bin/activate"
source /venv/bin/activate

echo
echo "Exporting environment variable DJANGO_SETTINGS_MODULE=config.environments.ebs"
export DJANGO_SETTINGS_MODULE=config.environments.ebs
echo

history -s python server/manage.py dbshell
history -s python server/manage.py shell_plus

echo "****************"
echo "* You are now in"
echo "*"
echo -n "* "
cat service-name.conf
echo "*"
echo "****************"
echo

export PS1="\[$(tput bold)\]\[$(tput setaf 6)\]\u:/\W\\$ \[$(tput sgr0)\]"

from config.settings import *
from config.secrets.ebs_secrets import *


ALLOWED_HOSTS = ['little-service.us-west-2.elasticbeanstalk.com']

STATIC_URL = 'https://s3-us-west-2.amazonaws.com/service-static/little-service/'

DEBUG = False

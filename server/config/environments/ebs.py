from config.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': 'little-service-micro-db.cfgr60m9hv2x.us-west-2.rds.amazonaws.com',
        'PORT': '3306',
        'NAME': 'little_service_db',
        'USER': 'root',
        'PASSWORD': 'dD2Poap3ytAgqazah',
    }
}

ALLOWED_HOSTS = ['little-service.us-west-2.elasticbeanstalk.com']

STATIC_URL = 'https://s3-us-west-2.amazonaws.com/service-static/little-service/'

DEBUG = False

from config.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': 'aa1cyclmmtodts2.cfgr60m9hv2x.us-west-2.rds.amazonaws.com',
        'PORT': '3306',
        'NAME': 'little_service_db',
        'USER': 'root',
        'PASSWORD': 'dD2Poap3ytAgqazah',
    }
}

ALLOWED_HOSTS = ['little_service.us-west-2.elasticbeanstalk.com']

DEBUG = True

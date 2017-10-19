from scheduler_service.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': 'docker.for.mac.localhost',
        'PORT': '3306',
        'NAME': 'little_service_db',
        'USER': 'root',
        'PASSWORD': '',
    }
}

ALLOWED_HOSTS = ['127.0.0.1']

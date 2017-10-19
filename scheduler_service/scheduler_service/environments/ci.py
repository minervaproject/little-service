from scheduler_service.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': '127.0.0.1',
        'PORT': '3306',
        'NAME': 'scheduler_db',
        'USER': 'root',
        'PASSWORD': '',
    }
}

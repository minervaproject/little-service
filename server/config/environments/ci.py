from ..settings import *


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': '127.0.0.1',
        'PORT': '3306',
        'NAME': 'circle-db',
        'USER': 'root',
        'PASSWORD': '',
    }
}

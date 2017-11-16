from little_service_app.views import IndexView
from django.conf.urls import url
from django.contrib import admin

urlpatterns = [
    url(r'^$', IndexView.as_view(), name='index'),
    url(r'^admin/', admin.site.urls),
]

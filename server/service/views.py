# -*- coding: utf-8 -*-
from __future__ import absolute_import, unicode_literals

import json
from celery import shared_task
from django.http import HttpResponse
from django.views.generic import TemplateView
from service.models import Banner
from service.models import Counter


class IndexView(TemplateView):
    template_name = "indexview.html"

    def get_context_data(self, **kwargs):

        counter = Counter.objects.last()
        if not counter:
            counter = Counter.objects.create()
        counter.count += 1
        counter.save()

        banner = Banner.objects.last()
        if not banner:
            banner = Banner.objects.create(
                text="✨ Hello, world ✨")
            banner.save()

        return {
            "count": counter.count,
            "text": banner.text,
        }


# TODO: TEST CELERY
# @shared_task
# def run_scheduler(*args):
#     scheduler = SchedulerService(use_cache=True)
#     scheduler.build_objects_from_cache()
#     scheduler.run()


# def scenario_start(request):
#     run_scheduler.delay()
#     return HttpResponse(Scenario.objects.latest("updated_on").id)

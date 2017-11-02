# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

class FirstTestCase(TestCase):
    def setUp(self):
        self.test = 2

    def test_instance_variables(self):
        self.assertEqual(self.test, 2)

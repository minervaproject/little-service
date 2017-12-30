import MySQLdb

from django.conf import settings
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def handle(self, *args, **options):

        host = settings.DATABASES["default"]["HOST"]
        dbname = settings.DATABASES["default"]["NAME"]
        user = settings.DATABASES["default"]["USER"]
        passwd = settings.DATABASES["default"]["PASSWORD"]

        db = MySQLdb.connect(host=host, user=user, passwd=passwd, db=dbname)
        cursor = db.cursor()

        cursor.execute("ALTER DATABASE `{}` CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci'".format(dbname))

        sql = "SELECT DISTINCT(table_name) FROM information_schema.columns WHERE table_schema = '{}'".format(dbname)
        cursor.execute(sql)

        results = cursor.fetchall()
        for row in results:
          sql = "ALTER TABLE `{}` convert to character set DEFAULT COLLATE DEFAULT".format(row[0])
          cursor.execute(sql)
        db.close()

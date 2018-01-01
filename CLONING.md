1. Create a new repository using the GitHub GUI. Customize the repository settings the way you like. I tend to turn everything off and protect the `master` branch from force-pushes. The first time this was done is for the `stats-service`, so it will be the name used in examples here.
2. Clone this repository into the same work directory as `little-service`. For now, use:
```
cp -R little-service/* stats-service/
cp -R little-service/.circleci stats-service/
cp -R little-service/.gitignore stats-service/
```
but we need a more sustainable way to pull the base service files.
3. The following renames need to be automated, but will be noted here for now:
```
.circleci/config.yml: working_directory: little_service -> stats-service
.ebextensions: server_name stats-service.us-west-2.elasticbeanstalk.com; certificate URLs
server/config/environments/ebs.py: database host, name, user, password, ALLOWED_HOSTS
server/config/environments/local.py: database name
Dockerrun.aws.json: Image Name -> stats-service
```
4. Create a local MySQL database: `mysqladmin -u root create stats-service-db`.
5. Create a file in `server/config/secrets/` named `local_secrets.py` with contents like the following:
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'HOST': 'docker.for.mac.localhost',
        'PORT': '3306',
        'NAME': 'stats-service-db',
        'USER': 'root',
        'PASSWORD': '',
    }
}
```
6. Start the web/local celery container with `make`.
7. Visit http://127.0.0.1:88/

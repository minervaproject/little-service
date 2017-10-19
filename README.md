# Scheduler service

The goals of this project is to 1) create a standalone scheduler service that solves a product need of iteratively generating and verifying schedules, can be used with minimal engineering intervention, and 2) exploring the possibility of a templated base service infrastructure for ALF projects.

For such a template to be useful, it necessarily has to share many of the technologies already used by ALF in picasso, and include features for a developer to easily and confidently start a production-ready service:
- Django 1.11 / Python 2.7
    - Strong patterns for API endpoints, both reading and writing, as well as permissions, may be needed here. It's unclear whether DRF should be standard.
- Build and Deploy (TBD)
- Circle / Testing
- Local Development
- Monitoring / Alerts (TBD)
- Logging (TBD)

The descriptions and roadmaps below indicate progress in each of those areas.

### Django

The Django installation is created in a folder named `application_service`, as in `scheduler_service`. A `static` folder is created for static assets. `settings.py` within a nested `application_service` contains the master configuration, and the built-in Django support for environment setting modules is used to set database configuration for Circle and local. URLs are indicated in `urls.py` as well.

The application code itself is in a folder within, called `application`, as in `scheduler`. This application is registered with the Django installation, and its structure is mostly simple. `apps.py` is used to store some application-level configuration, `celery.py` currently only supports the local development environment's Redis, and `views.py` contain controller code. The `templates` folder contains view-level code, and `migrations` has migrations.

Roadmap
- [ ] Static asset deployment strategy.
- [ ] Per-application URL routing.

### Build and Deploy

The build process uses Amazon CodeBuild, which takes the specs in `buildspec.yml` and builds a single webserver Docker image and registers it with Amazon ElasticContainerRegistry, which in theory should allow it to be deployable.

Roadmap
- [ ] Production environment with MySQL, Redis, Celery workers.
- [ ] Deployment scripts.
- [ ] Some strategy for scaling.
- [ ] Strategy for storing secrets.

### Circle
Circle 2.0 makes use of Docker containers, so one Python and one MySQL container is specified in `.circleci/config.yml`. Both containers cache dependencies based on changes to `requirements.in` for Django, and save them to `venv`. Then a migration is run on a fresh database, followed by unit tests. All of the dependency setup and entrypoint scripting is done within the Circle configuration file, which needs to be kept parallel with the local and production (if any) scripts.

Roadmap:
- [ ] Container for Celery/Redis to test scheduled/delayed tasks.
- [ ] Smarter healthcheck to wait for database readiness.
- [ ] Test artifacts/reporting.
- [ ] Integration tests.

### Local Development

/Quick Start:

1. Install and update the stable version of [Docker for Mac](https://docs.docker.com/docker-for-mac/install/).
   You need to run Docker locally, but you do not need to create an account/sign-in.

2. Create your local database. The database name that this little service assumes is little_service_db.

3. If you don't already have Redis, install Redis.

4. Build the web server and run it locally:
```
docker-compose build && docker-compose run --service-ports web
```

5. Go to http://127.0.0.1:90/ - You should see the number under "Hello, World" increment with every refresh.

/Quick Start End.

Code changes will automatically trigger Django's server restart.

Attach to a running web server:
```
docker exec -it scheduler_web_1 bash
source /venv/bin/activate
DJANGO_SETTINGS_MODULE=scheduler_service.environments.local python scheduler_service/manage.py
```

`docker-compose.yml` specifies the containers needed for local development. Parallel to Circle's configuration, one Python container is built based on `Dockerfile`, with dependencies installed and caches locally. There is also a minimal MySQL container that reads and writes directly to a developer's local MySQL database library (which may become problematic). On start, `docker-entrypoint.sh` is used to activate `venv`, migrate, start a Celery worker in the background, and finally start the web server.

Roadmap:
- [ ] Figure out Docker network optimization.
- [ ] Separate file location for persistent MySQL database.
- [ ] Shell features and parity with picasso.
- [ ] Container for Celery/Redis.
- [ ] Smarter healthcheck to wait for database readiness.
- [ ] Integration tests.
- [ ] Figure out Unicode support for database.

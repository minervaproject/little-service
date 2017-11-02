# Little Service

A templated base service infrastructure for ALF projects.

For such a template to be useful, it necessarily has to share many of the technologies already used by ALF in picasso, and include features for a developer to easily and confidently start a production-ready service:
- Django 1.11 / Python 2.7
    - Strong patterns for API endpoints, both reading and writing, as well as permissions, may be needed here. It's unclear whether DRF should be standard.
    - TODO: We may want to discuss starting with Python 3.
- Build and Deploy
- Circle / Testing
- Local Development Process
- Monitoring / Alerts (TBD)
- Logging (TBD)

The descriptions and roadmaps below indicate progress in each of those areas.

### Django

The Django installation is created in a folder named `application_service`, as in `scheduler_service`. A `static` folder is created for static assets. `settings.py` within a nested `application_service` contains the master configuration, and the built-in Django support for environment setting modules is used to set database configuration for Circle and local. URLs are indicated in `urls.py` as well.

The application code itself is in a folder within, called `application`, as in `scheduler`. This application is registered with the Django installation, and its structure is mostly simple. `apps.py` is used to store some application-level configuration, `celery.py` currently only supports the local development environment's Redis, and `views.py` contain controller code. The `templates` folder contains view-level code, and `migrations` has migrations.

Roadmap
- [ ] Static asset deployment strategy.
- [ ] Per-application URL routing.
- [ ] Celery/Redis within applications.
- [ ] API / login auth

### Build and Deploy

The build process uses Amazon CodeBuild, which takes the specs in `buildspec.yml` and builds a single web server Docker image and registers it with Amazon ElasticContainerRegistry. In the future, we may want some kind of multi-container configuration.

AWS steps, which we hope to be able to write into a CLI script someday:

1. Go to AWS, and go to AWS CodePipeline.

2. Click "Create pipeline"

3. Call the pipeline the name of your project.

4. Select Github as the source on the next page.

5. It will allow you to connect to Github and choose your repository and branch.

6. On the next page, select "AWS CodeBuild" as your Build provider.

7. Configure your project. Select "Create a new build", use your project name.

8. Environment/how to build. Select "Use an image managed by AWS CodeBuild", Operating System "Ubuntu", Runtime "Docker", Version "aws/codebuilder/docker:1.12.1", Build specification "Use the buildspec.yml in the source code root directory".

9. AWS CodeBuild service role should be "Create a service role in your account". Name role name whatever you want.

10. Under Advanced, it's really important to check "Privileged - Enable this flag if you want to build Docker images or want your builds to get elevated privileges". You probably don't need to change timeout. Compute type may vary depending on the project.

THEN, DO NOT SAVE BUILD PROJECT. GO TO A SEPARATE TAB.

11. Go to EC2 Container service.

12. Click "Create repository" button. Name your repo the name of your project.

13. Click done.

14. Now you should see the repo ARN and URI. This is where the Docker images go.

The URI will look something like this:
579419983247.dkr.ecr.us-west-2.amazonaws.com/little_service

NOW, GO BACK TO PREVIOUS TAB.

15. Add following environment variables according to your URI:
name                value             type
IMAGE_REPO_NAME     little_service    plaintext
AWS_ACCOUNT_ID      579419983247      plaintext
IMAGE_TAG           latest            plaintext     // this is not from the URI, just default
AWS_DEFAULT_REGION  us-west-2         plaintext

16. Now we can save the build project! After it's saved, we can do "Next Step."

17. Deploy <Note: we skipped this initially, and came back to it after step 21 and did the following.>

  17.a. Go to Elastic Beanstalk
  17.b. Top right, it says Create new application, create one for your project.
  17.c. Create an environment for your new application.
  17.d. Choose Web server environment.
  17.e. Environment name ex: "little_service-production", domain name whatever your project is ex: "little_service".
  17.f. Platform is "preconfigured platform", "Docker."
  17.g. "Sample application" is fine.
  17.h. Then do "Configure more options."
  17.i. "Low cost" is fine.
  17.j. Create environment.
  17.k. You should be at All Applications > little_service > little_service-production. And now it does something. It will take forever.
  17.l. Now you should see a dashboard with an Environment ID and a URL. If you go to the URL, you should see a template AWS page. ex. little_service.us-west-2.elasticbeanstalk.com
  17.m. Go to config and create an RDS instance.

  17.n. When you're done, go back to AWS CodePipeline, and under Source and Build add stage "Deploy". Add an action with Action category "Deploy" and name "deploy". Deployment provider is ElasticBeanstalk. Choose your service from the dropdowns. Input artifacts should be "MyAppBuild." Add action, save pipeline.
  Then release change and see what happens.

18. AWS Service Role: there should be a default one (AWS-CodePipeline-Service). If not, I'm sorry.

19. Review all the things. Create pipeline.

20. To test it, click "Release Change." And now we wait.
(If you want to look at the progress, you can go to CodeBuild and select your project. And then click on the thing under Build Run.)

21. If you get the error:

MessageError while executing command: $(aws ecr get-login --region $AWS_DEFAULT_REGION). Reason: exit status 255

Go to IAM, and find your thing under Roles (for us, this is code-build-little_service-service-role). Do attach policy, check:
AmazonEC2ContainerRegistryPowerUser

Note: Retrying from the CodeBuild dashboard does not work. Go do "Release change" again.

Roadmap
- [ ] Production environment with MySQL, Redis, Celery workers.
- [ ] Deployment scripts.
- [ ] Some strategy for scaling.
- [ ] Strategy for storing secrets.

### Circle
Circle 2.0 makes use of Docker containers, so one Python and one MySQL container is specified in `.circleci/config.yml`. Both containers cache dependencies based on changes to `requirements.in` for Django, and save them to `venv`. Then a migration is run on a fresh database, followed by unit tests. All of the dependency setup and entrypoint scripting is done within the Circle configuration file, which needs to be kept parallel with the local and production (if any) scripts.

Adding project to CircleCI

1. Go to CircleCI, click on "Projects" in the sidebar.

2. Click "Add Projects"

3. You should see the new repo in the list - this is based on Github. There should be a "Setup Project" button next to it. Click the button.

4. Default OS is Linux, platform is 2.0, language is Python. Make these selections and click "Start building" at the bottom of the page.

5. Then you should see your dummy unit test pass.

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
- [ ] Django Admin

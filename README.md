Discussion: https://docs.google.com/document/d/1wVIxxvxMuhZVlex0YAVicVLE4l_RvGnYavccD4Nml10/edit

# Building a Reusable Little Service
## Django/Celery on Docker, CodePipeline, Elastic Beanstalk, with an RDS database.


### Motivation

[Image of classroom]

Minerva's Active Learning Forum (ALF) started as just an online dashboard and virtual classroom. As Minerva grew, so did the requirements for this platform, storing more types of data and providing more features and views. Originally a full-stack web application with [Backbone](http://backbonejs.org/) and [Marionette.js](https://marionettejs.com/) on a [Django](https://www.djangoproject.com/) back-end, the monolithic codebase (internally named `picasso`) now hosts over a dozen [Django apps](https://docs.djangoproject.com/en/1.11/ref/applications/), scores of models, a full suite of tests that require half an hour or more to run, and nearly a hundred shared dependencies for the back-end alone.

To improve development, testing, and deployment speed, as well as reduce cognitive overhead, the ALF team decided to move toward a service-oriented architecture (SOA) that interacted through clearly defined, ideally [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer), APIs. We have already seen great success with running [Licode](http://lynckia.com/licode/), our A/V system, as a service, and more recently with refactoring "ClassGrader", where faculty grade student-submitted assignments, as a React webapp.


### Requirement definition

The first step we made towards an SOA was a brainstorm session with three ALF engineers. First, we listed ALF's dependencies that were already considered standalone services. One is our [Pubsub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) server, which allowed real-time messages and events to be sent between users in the same classroom. Another example is [Looker](https://looker.com/), a third-party application that we connect directly to our database.

Then, we started breaking down feature seams of ALF that could (should) be similarly independent. In the front-end, for example, we have a set of dashboards that only faculty can view, displaying grades and other data for students in their sections, pages for section administration and changing enrollments, and pages for modifying individual classes. Many models and patterns are certainly shared conveniently between them, but those models (and assets and dependencies) become intertwined more tightly and unpredictably as we build more views that require different combinations of them. In the back-end, we might want monitoring and stats collection and aggregation functionality to be independently executed, as a sudden influx of events could (and have) degraded response times for general web requests on the same shared server. Emails and interfaces for third-party integrations like Google Docs are also suitable for abstraction, as we have various implementations throughout the codebase.

With this in mind, we wanted to experiment with building a templated base infrastructure for ALF services. For such a template to be useful, it necessarily has to share many of the technologies already used by ALF in `picasso`, and include features for a developer to easily and confidently start a production-ready service. We decided that, for an MVP, the stack would include the following:
- Django 1.11 / Python 2.7
    - Strong patterns for API endpoints, both reading and writing, as well as permissions, will be needed here. It's unclear whether DRF, [Django Rest Framework](http://www.django-rest-framework.org/), should be standard.
    - Roadmap: We may want to discuss making Python 3 the default.
- Monitoring and alerts
    - Currently, only the built-in AWS monitoring is implemented.
- Automated building, testing, and deployment
    - A CI/CD pattern seemed the most robust, particularly with the deployment abstraction EBS provides, and the automatic hooks from CodePipeline.
- Simple local development environment setup
    - To meet this need, as well as uniform local/testing/deployment environments, we decided to use containerization with Docker to deterministically create images and isolate dependencies.


### Background learning

To gain a foundational understanding of a service-oriented architecture, the author (Cheng, the primary engineer on the project), spent some time researching and learning high-level concepts. Two books, [Building Microservices by Sam Newman](http://samnewman.io/books/building_microservices/), and [Production-Ready Microservices](http://shop.oreilly.com/product/0636920053675.do) by Susan J. Fowler, were invaluable. The usual online resources and documentation for Docker, Circle, and AWS were accessed when they were needed.


### Implementation details

#### Local layer

##### Docker

Developers install native Docker for their operating system, which runs as a service in the background.  `docker-compose.yml` specifies the containers needed for local development, and currently only one Python container is needed. This container is described by `Dockerfile`, which specifies dependency installation and caches locally for each additional layer of dependencies. On start, `docker-entrypoint.sh` is used to activate Python's `venv`, run any Django migrations, start a Celery worker in the background for asynchronous tasks (a native Redis is used for this), and finally start the web server worker.

##### Django

By convention from Seminar, the Django installation is created in a folder named `server`. A `static` folder is created for static assets. `settings.py` within `config` contains the master configuration, and the built-in Django support for environment setting modules is used to set database configuration for Circle and local environments. URLs are indicated in `urls.py` as well.

The application code itself is in another folder, called `little_service_app`. This application is registered with the Django installation, and its structure follows Django conventions. `apps.py` is used to store some application-level configuration, `celery.py` currently only supports the local development environment's Redis, and `views.py` contains controller code. The `templates` folder contains view-level code, and `migrations` has migrations. No default front-end has been added yet, so built-in Django templating is used.

Roadmap:
- [ ] Figure out Docker network optimization, with a container for MySQL for local development.
- [ ] Separate file location for persistent MySQL database for local development.
- [ ] Shell features, both at the container and application level.
- [ ] Container for Celery/Redis.
- [ ] Smarter healthcheck to wait for database readiness on start.
- [ ] Front-end / integration tests.
- [ ] Unicode support by default for database.
- [ ] Django Admin.

#### Test layer

Circle 2.0 makes use of Docker containers, so one Python and one MySQL container is specified in `.circleci/config.yml`. Both containers cache dependencies based on changes to `requirements.in` for Django, and save them to `venv`. Then migrations are run on a fresh database, followed by unit tests. All of the dependency setup and entrypoint scripting is done within the Circle configuration file, which needs to be kept parallel with the local and production Dockerfiles.

Roadmap:
- [ ] Container for Celery/Redis, tests.
- [ ] Smarter healthcheck to wait for database readiness.
- [ ] Test artifacts/reporting.
- [ ] Integration tests.

#### Deployment layer

The build process uses Amazon CodeBuild, which takes the specs in `buildspec.yml` and builds a single web server Docker image and uploads it to Amazon ElasticContainerRegistry. Then, CodePipeline takes that build and deploys it with ElasticBeanstalk.

Roadmap
- [ ] Container for Celery/Redis.
- [ ] Deployment scripts.
- [ ] Some strategy for scaling.
- [ ] Strategy for storing secrets.
- [ ] Static asset deployment strategy.
- [ ] API / login auth / general security.


### Future aspirations

Finally, the overall cloning of the service could be automated significantly. We could write a script to copy files from the repository and rename appropriate strings such as service names. We could also write a script to automate AWS setup, the complex details of which can be found below.


# Technical Details


## Local Development

Quick Start:

1. Install and update the stable version of [Docker for Mac](https://docs.docker.com/docker-for-mac/install/). You need to run Docker locally, but you do not need to create an account/sign-in.
2. Create a local MySQL database and update `environments/local.py` accordingly. The database name that this little service assumes is `little_service_db`.
3. If you don't already have Redis, install Redis, and update `celery.py` accordingly.
4. Build the web server and run it locally:
```
docker-compose build && docker-compose run --service-ports web
```
5. Go to http://127.0.0.1:88/ - You should see the number under "Hello, World" increment with every refresh.

Code changes will automatically trigger Django's server restart.

Attach to a running web server:
```
docker exec -it scheduler_web_1 bash
source /venv/bin/activate
DJANGO_SETTINGS_MODULE=scheduler_service.environments.local python scheduler_service/manage.py
```


## Testing on CircleCI

1. Go to CircleCI, click on "Projects" in the sidebar.
2. Click "Add Projects".
3. You should see the new repo in the list - this is based on Github. Click "Setup Project".
4. Default OS is Linux, platform is 2.0, language is Python. Make these selections and click "Start building" at the bottom of the page.
5. Then you should see your dummy unit test pass.


## Building and Deploying on AWS

1. Go to AWS CodePipeline.
2. Click "Create pipeline".
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
The URI will look something like this: `###########.dkr.ecr.us-west-2.amazonaws.com/little_service`
NOW, GO BACK TO THE PREVIOUS TAB.
15. Add following environment variables according to your URI:
````
name                value             type
IMAGE_REPO_NAME     little_service    plaintext
AWS_ACCOUNT_ID      ###########       plaintext
IMAGE_TAG           latest            plaintext     // this is not from the URI, just default
AWS_DEFAULT_REGION  us-west-2         plaintext
````
16. Now we can save the build project! After it's saved, we can do "Next Step."
17. AWS Service Role: there should be a default one (AWS-CodePipeline-Service).
18. Click Create pipeline.
19. Setting up a deployment environment:
19.a. Go to Elastic Beanstalk, and click "Create new application" on the top right.
19.b. Create an environment for your new application.
19.c. Choose Web server environment.
19.d. Environment name example: "little_service-production", domain name example: "little_service".
19.e. Platform is "preconfigured platform", "Docker."
19.f. "Sample application" is fine.
19.g. Then do "Configure more options."
19.h. "Low cost" is fine.
19.i. Create environment.
19.j. You should be at All Applications > little_service > little_service-production. Wait a little bit for AWS to provision all the resources for you.
19.k. Now you should see a dashboard with an Environment ID and a URL. If you go to that URL, you should see a template AWS page.
19.l. Create an RDS instance separately, on the RDS dashboard.
19.m. Go back to AWS CodePipeline, and under Source and Build add stage "Deploy". Add an action with Action category "Deploy" and name "deploy". Deployment provider is Elastic Beanstalk. Choose your service from the dropdowns. Input artifacts can be default "MyAppBuild." Add action, save pipeline.
20. To test it, click "Release Change." If you want to look at the progress, you can go to CodeBuild and select your project. And then click on the project under Build Run.)

### Troubleshooting

#### MessageError while executing command: $(aws ecr get-login --region $AWS_DEFAULT_REGION). Reason: exit status 255

Go to IAM, and find your role under Roles (for us, this is code-build-little_service-service-role). Under "Attach Policy", check "AmazonEC2ContainerRegistryPowerUser" and add it.

Note: Retrying builds from the CodeBuild dashboard does not work. Do "Release change" from CodePipeline to ensure that all steps run.

## Teardown from AWS (Costly items only)

1. Delete the Application from Elastic Beanstalk.
2. Delete images from EC2 Container Service.

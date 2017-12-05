Django

Roadmap:
- [ ] Figure out Docker network optimization, with a container for MySQL for local development.
- [ ] Separate file location for persistent MySQL database for local development.
- [ ] Shell features, both at the container and application level.
- [ ] Container for Celery/Redis.
- [ ] Smarter healthcheck to wait for database readiness on start.
- [ ] Front-end / integration tests.
- [ ] Unicode support by default for database.
- [ ] Django Admin.

Circle

Roadmap:
- [ ] Container for Celery/Redis, tests.
- [ ] Smarter healthcheck to wait for database readiness.
- [ ] Test artifacts/reporting.
- [ ] Integration tests.

Deployment

Roadmap
- [ ] Container for Celery/Redis.
- [ ] Some strategy for scaling.
- [ ] API / login auth / general security.

## Local Development

Quick Start:

1. Create a local MySQL database: `mysqladmin -u root create stats-service-db`.
2. If you don't already have Redis, install Redis, and update `celery.py` accordingly.
3. Build the web server and run it locally:
```
docker-compose build && docker-compose run --service-ports web
```
4. Go to http://127.0.0.1:88/ - You should see the number under "Hello, World" increment with every refresh.

Code changes will automatically trigger Django's server restart.

Attach to a running web server:
```
sudo docker exec -it $(sudo docker ps -q) bash
source /venv/bin/activate
DJANGO_SETTINGS_MODULE=config.environments.local python server/manage.py
```


## Testing on CircleCI

1. Go to CircleCI, click on "Projects" in the sidebar.
2. Click "Add Projects".
3. You should see the new repo in the list - this is based on Github. Click "Setup Project".
4. Default OS is Linux, platform is 2.0, language is Python. Make these selections and click "Start building" at the bottom of the page.
5. Then you should see your dummy unit test pass.


## Building and Deploying on AWS


### RDS
1. Create an RDS instance, on the RDS dashboard. Add credentials to `config/environments/ebs.py`.
2. The database needs a security group that allows traffic in and out, if it's in a VPC.


### Elastic Container Service
1. Go to EC2 Container service.
2. Click "Create repository" button. Name your repo the name of your project.
3. Click done.
4. Now you should see the repo ARN and URI. This is where the Docker images go. The URI will look something like this: `###########.dkr.ecr.us-west-2.amazonaws.com/stats-service`.


### CodePipeline
1. Go to AWS CodePipeline, and click "Create pipeline".
2. Call the pipeline the name of your project.
3. Select Github as the source on the next page.
4. It will allow you to connect to Github and choose your repository and branch.
5. On the next page, select "AWS CodeBuild" as your Build provider.
6. Configure your project. Select "Create a new build", use your project name.
7. Environment/how to build. Select "Use an image managed by AWS CodeBuild", Operating System "Ubuntu", Runtime "Docker", Version "aws/codebuilder/docker:1.12.1", Build specification "Use the buildspec.yml in the source code root directory".
8. AWS CodeBuild service role should be "Create a service role in your account". Name role something like `code-build-stats-service-role`.
9. Under Advanced, it's really important to check "Privileged - Enable this flag if you want to build Docker images or want your builds to get elevated privileges". You probably don't need to change timeout. Compute type may vary depending on the project.
10. Add following environment variables according to the URI from Elastic Container Service above:
````
name                value             type
IMAGE_REPO_NAME     stats-service     plaintext
AWS_ACCOUNT_ID      ###########       plaintext
IMAGE_TAG           latest            plaintext     // this is not from the URI, just default
AWS_DEFAULT_REGION  us-west-2         plaintext
````
11. Now we can save the build project! After it's saved, we can do "Next Step". Choose "No Deployment" for now.
12. AWS Service Role: there should be a default one (AWS-CodePipeline-Service).
13. Click Create pipeline.
14. Go to IAM, and find the role from step 8 in Roles. Under "Attach Policy", check "AmazonEC2ContainerRegistryPowerUser" and add it.


### Elastic Beanstalk
1. Go to Elastic Beanstalk, and click "Create new application" on the top right.
2. Create an environment for your new application.
3. Choose Web server environment.
4. Environment name example: "little_service-production", domain name example: "little_service".
5. Platform is "preconfigured platform", "Docker."
6. "Sample application" is fine.
7. Then do "Configure more options."
8. "Low cost" is fine.
9. Create environment.
10. You should be at All Applications > little_service > little_service-production. Wait a little bit for AWS to provision all the resources for you.
11. Now you should see a dashboard with an Environment ID and a URL. If you go to that URL, you should see a template AWS page.
12. Go back to AWS CodePipeline, and under Source and Build add stage "Deploy". Add an action with Action category "Deploy" and name "deploy". Deployment provider is Elastic Beanstalk. Choose your service from the dropdowns. Input artifacts can be default "MyAppBuild." Add action, save pipeline.
13. To test it, click "Release Change." If you want to look at the progress, you can go to CodeBuild and select your project. And then click on the project under Build Run.


### Temporary HTTPS certificate
1. Use https://letsencrypt.org/ as the CA.
2. `wget https://dl.eff.org/certbot-auto`
3. `chmod +x certbot-auto`
4. `./certbot-auto --no-bootstrap certonly`
5. Use option 2, "Spin up a temporary webserver (standalone)", and input the service's domain name.
6. `sudo aws s3 cp /etc/letsencrypt/live/little-service.us-west-2.elasticbeanstalk.com/fullchain.pem s3://service-keys/little-service/`
7. `sudo aws s3 cp /etc/letsencrypt/live/little-service.us-west-2.elasticbeanstalk.com/privkey.pem s3://service-keys/little-service/`
8. Redeploy from CodePipeline, and it should work.


### Secrets (Only if you need to update them for the EBS environment)

1. To acquire: `aws s3 cp s3://service-keys/little-service/ebs_secrets.py server/config/secrets/ebs_secrets.py`.
2. To update: `aws s3 cp server/config/secrets/ebs_secrets.py s3://service-keys/little-service/ebs_secrets.py`.

This is automatically pulled in by CodeBuild when building the container.


## Teardown from AWS (Costly items only)

1. Delete the Application from Elastic Beanstalk.
2. Delete images from EC2 Container Service.

# MYQ dev environment

## Install

To install project:
- clone `myq` project with submudules from repository (`git clone myq –recurse-submodules`)
- configure .env.local variables (change `prod` to `dev`)
- run `make install` - second time when you open environment enough to run `make start`

all commands described in `./Makefile`

 ## Run unit tests
1) Use `./myq_back/.env.test` instead of `./myq_back/.env.local`
2) Create test DB `make db-create-test`
3) Load test fixtures `make load-fixtures-test`
4) Run tests `docker-compose exec php php bin/phpunit`

 ## Run jenkins

1) Run jenkins
```
docker build -t myq_jenkins ./docker/jenkins
    
docker run --name myq_jenkins --rm -d -p 8080:8080 -p 50000:50000 \
-v $PWD/docker/jenkins/jenkins_home:/var/jenkins_home \
-v '/var/run/docker.sock:/var/run/docker.sock' \
-v $PWD/docker/volumes:/srv/host_volumes \
myq_jenkins
```
2) Create new credential for GitHub `login/password`
3) Create 2 new Pipeline items (**MYQBack, MYQFront**) `Pipeline script from SCM` with previously created credentials
4) Create Jenkins credentials
- `myq` secret file - myq_back environment variables
- `myq_test` secret file - myq_back environment variables with test credentials
- `myq_front` secret file - myq_front environment variables

## Mailcatcher
Mailcatcher is available by URL http://localhost:1080/

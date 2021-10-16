install:
	docker-compose up -d --build
	docker-compose exec php composer install
	docker-compose exec php bin/console lexik:jwt:generate-keypair
	docker-compose exec php bin/console doctrine:schema:update --force --dump-sql
	docker-compose exec node npm install
	docker-compose exec node npm run start

start:
	docker-compose up -d
	docker-compose exec node npm run start

back_container:
	docker-compose exec php bash

back_install-dependencies:
	docker-compose exec php composer install

back_update-dependencies:
	docker-compose exec php composer update

db-create: ## Build the db, control the schema validity
	docker-compose exec php bin/console doctrine:cache:clear-metadata
	docker-compose exec php bin/console doctrine:database:drop --if-exists --force
	docker-compose exec php bin/console doctrine:database:create --if-not-exists
	docker-compose exec php bin/console doctrine:schema:drop --force
	docker-compose exec php bin/console doctrine:schema:create
	docker-compose exec php bin/console doctrine:schema:validate

db-create-test: ## Build the db, control the schema validity - test environment
	docker-compose exec php bin/console doctrine:cache:clear-metadata --env=test
	docker-compose exec php bin/console doctrine:database:drop --if-exists --force --env=test
	docker-compose exec php bin/console doctrine:database:create --if-not-exists --env=test
	docker-compose exec php bin/console doctrine:schema:drop --force --env=test
	docker-compose exec php bin/console doctrine:schema:create --env=test
	docker-compose exec php bin/console doctrine:schema:validate --env=test

db-update: ## DB Schema update
	docker-compose exec php bin/console doctrine:schema:update --force --dump-sql

db-update-test: ## DB Schema update
	docker-compose exec php bin/console doctrine:schema:update --force --dump-sql --env=test

back_cc: ## Clear cache
	docker-compose exec php bin/console c:c

back_router: ## Routes list
	docker-compose exec php bin/console debug:router

back_scan-translations:
	docker-compose exec php bin/console translation:extract uk --dir=./templates/ --output-dir=./translations
	docker-compose exec php bin/console translation:extract uk --dir=./src/ --output-dir=./translations

back_cs: ## Fix code styles
	docker-compose exec php php-cs-fixer fix

load-fixtures: ## load fixtures and check the migration status
	docker-compose exec php bin/console doctrine:fixtures:load -n
	docker-compose exec php bin/console doctrine:migration:status

load-fixtures-test: ## load fixtures and check the migration status
	docker-compose exec php bin/console doctrine:fixtures:load -n --env=test
	docker-compose exec php bin/console doctrine:migration:status --env=test

back_run-tests: ## run tests
	docker-compose exec php bin/console doctrine:fixtures:load -n --env=test
	docker-compose exec php env XDEBUG_MODE=coverage bin/phpunit --coverage-html cover

front_start:
	docker-compose exec node npm run start

front_scan-translations:
	docker-compose exec node i18next-scanner --config i18next-scanner.config.js

front_install-dependencies:
	docker-compose exec node npm install

front_container:
	docker-compose exec node bash

rebuild_prod_front:
	docker build -t myq_node -f ./myq_front/docker/node/prod/Dockerfile ./myq_front
	docker run --rm -t -d --name myq_node --env-file ./myq_front/.env myq_node bash
	docker exec myq_node npm i
	docker exec myq_node npm run webpack:build
	docker cp myq_node:/app/dist/. ./myq_back/public/front/
	docker stop myq_node

build_prod_environment:
	docker build -t myq_php --no-cache -f ./myq_back/docker/php-fpm/prod/Dockerfile ./myq_back
	docker build -t myq_nginx --no-cache -f ./myq_back/docker/nginx/prod/Dockerfile ./myq_back
	docker build -t myq_mysql --no-cache -f ./myq_back/docker/mysql/prod/Dockerfile ./myq_back/docker/mysql

run_prod_environment:
	docker network create myq_network
	docker run -t -d --network=myq_network -p 3307:3306 --name myq_mysql --env-file ./myq_back/.env myq_mysql
	docker run -t -d --network=myq_network -v ${PWD}/docker/volumes/media:/var/www/html/public/media --name myq_php --env-file ./myq_back/.env myq_php php-fpm
	docker run -t -d --network=myq_network -v ${PWD}/docker/volumes/media:/var/www/html/public/media -p 80:80 --name myq_nginx --env-file ./myq_back/.env myq_nginx

start_prod_environment:
	docker start myq_mysql || true
	docker start myq_php || true
	docker start myq_nginx || true

stop_prod_environment:
	docker stop myq_mysql || true
	docker stop myq_php || true
	docker stop myq_nginx || true

remove_prod_environment:
	docker rm myq_mysql || true
	docker rm myq_php || true
	docker rm myq_nginx || true
	docker network rm myq_network || true

build_jenkins:
	docker build -t myq_jenkins ./docker/jenkins

run_jenkins:
	docker run --name myq_jenkins -d -p 8080:8080 -p 50000:50000 \
	-v ${PWD}/docker/jenkins/jenkins_home:/var/jenkins_home \
	-v '/var/run/docker.sock:/var/run/docker.sock' \
	-v ${PWD}/docker/volumes:/srv/host_volumes \
	myq_jenkins

run_portainer:
	docker volume create portainer_data
	docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

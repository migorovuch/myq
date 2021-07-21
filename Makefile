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

back_cc: ## Clear cache
	docker-compose exec php bin/console c:c

back_router: ## Routes list
	docker-compose exec php bin/console debug:router

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
	docker-compose exec php bin/phpunit -v

front_start:
	docker-compose exec node npm run start

front_scan-translations:
	docker-compose exec node i18next-scanner --config i18next-scanner.config.js

front_install-dependencies:
	docker-compose exec node npm install

front_container:
	docker-compose exec node bash

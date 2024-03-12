EXEC = docker compose exec php
CONSOLE = $(EXEC) bin/console

bash:
	$(EXEC) sh

start: ## Start the project
	docker compose build --no-cache
	docker compose up --pull always -d --wait
	@echo "started on http://localhost"

stop:
	docker compose down --remove-orphans

wp-run:
	 docker compose run symfony_assets_builder yarn install
	 $(CONSOLE) fos:js:dump --format=json --target=./public/js/fos_js_routes.json
	 docker compose run symfony_assets_builder yarn dev

wp-watch:
	 docker compose run symfony_assets_builder yarn watch

yarn-lint:
	 docker compose run symfony_assets_builder yarn lint

yarn-test-unit:
	 docker compose run symfony_assets_builder yarn test:unit

yarn-audit:
	docker compose run symfony_assets_builder yarn npm audit -A
	docker compose run symfony_assets_builder yarn npm audit -R

rebuild:
	docker compose down --remove-orphans
	aws ecr get-login-password --profile Devs-CTM --region eu-central-1 | docker login --username AWS --password-stdin 252252247358.dkr.ecr.eu-central-1.amazonaws.com
	docker compose pull
	docker pull 252252247358.dkr.ecr.eu-central-1.amazonaws.com/phpctm:latest
	docker compose build --no-cache
	docker compose up -d

cc:
	$(CONSOLE) cache:clear

cw:
	$(CONSOLE) cache:w

cc-test:
	$(CONSOLE) cache:clear --env=test --no-debug

diff:
	$(CONSOLE) doctrine:migrations:diff

dump-autoload:
	$(EXEC) composer dump-autoload

generate-migration:
	$(CONSOLE) c:c
	$(CONSOLE) doc:mi:diff

migrate:
	$(CONSOLE) c:c
	$(CONSOLE) doc:mi:mi --no-interaction --allow-no-migration
	$(CONSOLE) doctrine:schema:validate

fixture:
	$(CONSOLE) hautelook:fixtures:load -n

reset-db:
	$(CONSOLE) doctrine:database:create --if-not-exists
	$(CONSOLE) doctrine:schema:drop --force --full-database
	$(CONSOLE) doctrine:schema:create
	$(CONSOLE) doctrine:migrations:sync-metadata-storage
	$(CONSOLE) doctrine:migrations:version --add --all -n
	$(CONSOLE) hautelook:fixtures:load -n
	$(CONSOLE) petafuel:poll:bank-account:operation -f 2020-01-01
	$(CONSOLE) petafuel:poll:card:credit -f 2020-01-01
	$(CONSOLE) petafuel:poll:card:transaction -f 2020-01-01
	docker compose exec db /SQL/import-in-dev.sh
	$(CONSOLE) messenger:consume async card card_transaction clearing -vv --no-debug --time-limit=30

erp-procedures:
	docker compose exec db /SQL/import-in-dev.sh

lint:
	$(EXEC) composer validate
	$(CONSOLE) cache:clear
	$(CONSOLE) doctrine:schema:validate
	$(CONSOLE) lint:container
	$(CONSOLE) lint:twig src templates
	$(CONSOLE) lint:xliff translations
	$(CONSOLE) lint:yaml config fixtures src --parse-tags
	$(CONSOLE) debug:translation en_devel --only-unused || true
	$(CONSOLE) debug:translation en_devel --only-missing --domain=messages
	$(CONSOLE) debug:translation en_devel --only-missing --domain=validators
	$(EXEC) vendor/bin/psalm --no-cache

console:
	$(EXEC) bin/console

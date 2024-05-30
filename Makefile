EXEC = docker compose exec php
CONSOLE = $(EXEC) bin/console

bash:
	$(EXEC) sh

build:
	docker compose build --no-cache

start: ## Start the project
	docker compose up --pull always -d --wait
	@echo "started on http://localhost"

stop:
	docker compose down --remove-orphans

update-importmap:
	$(CONSOLE) importmap:outdated
	$(CONSOLE) importmap:update

sass-build:
	$(CONSOLE) sass:build --watch

dev-transupdate:
	$(CONSOLE) translation:extract --force --format=xlf12 --domain=messages en_devel

trans-unused-keys:
	$(CONSOLE) debug:translation en_devel --only-unused

trans-missing-keys:
	$(CONSOLE) debug:translation en_devel --only-missing

transupdate:
	$(CONSOLE) translation:extract --force --format=xlf12 --domain=messages --prefix='' fr
	$(CONSOLE) translation:extract --force --format=xlf12 --domain=messages --prefix='' en

cc:
	$(CONSOLE) cache:clear

cw:
	$(CONSOLE) cache:w

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

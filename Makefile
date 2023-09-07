##################
# Variables
##################

DOCKER_COMPOSE = docker-compose -f ./docker/docker-compose.yml
DOCKER_COMPOSE_PHP_FPM_EXEC = ${DOCKER_COMPOSE} exec -u www-data qvote-nginx-php-fpm

##################
# Docker compose
##################

build:
	${DOCKER_COMPOSE} build

start:
	${DOCKER_COMPOSE} start

stop:
	${DOCKER_COMPOSE} stop

up:
	${DOCKER_COMPOSE} up -d --remove-orphans

down:
	${DOCKER_COMPOSE} down

restart: stop start

dc_ps:
	${DOCKER_COMPOSE} ps

dc_logs:
	${DOCKER_COMPOSE} logs -f

dc_down:
	${DOCKER_COMPOSE} down -v --rmi=all --remove-orphans

dc_restart:
	make dc_stop dc_start


##################
# App
##################

app_bash:
	${DOCKER_COMPOSE} exec -u www-data qvote-nginx-php-fpm bash
php: app_bash

test:
	${DOCKER_COMPOSE} exec -u www-data qvote-nginx-php-fpm bin/phpunit
cache:
	docker-compose -f ./docker/docker-compose.yml exec -u www-data qvote-nginx-php-fpm bin/console cache:clear
	docker-compose -f ./docker/docker-compose.yml exec -u www-data qvote-nginx-php-fpm bin/console cache:clear --env=test

##################
# Database
##################

db_migrate:
	${DOCKER_COMPOSE} exec -u www-data qvote-nginx-php-fpm bin/console doctrine:migrations:migrate --no-interaction
migrate: db_migrate

db_diff:
	${DOCKER_COMPOSE} exec -u www-data qvote-nginx-php-fpm bin/console doctrine:migrations:diff --no-interaction
diff: db_diff

db_drop:
	docker-compose -f ./docker/docker-compose.yml exec -u www-data qvote-nginx-php-fpm bin/console doctrine:schema:drop --force


##################
# Static code analysis
##################

phpstan:
	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/phpstan analyse -c phpstan.neon; \
 	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/phpstan clear-result-cache

deptrac:
	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/deptrac analyze deptrac-layers.yaml
	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/deptrac analyze deptrac-modules.yaml

cs_fix:
	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/php-cs-fixer fix
linter: cs_fix

cs_fix_diff:
	${DOCKER_COMPOSE_PHP_FPM_EXEC} vendor/bin/php-cs-fixer fix --dry-run --diff

composer_validate:
	${DOCKER_COMPOSE_PHP_FPM_EXEC} composer validate

####
# Копирую обратно себе на хост из контейнера /var/www/vendor, так как не умею настроить автоматику
# особенности отклонения в развитии
# Иначе VSCode - PHP Intelephense ругается и не понимает классы Симфони и прочих пакетов
####
iam_special:
	docker cp qvote-nginx-php-fpm:/var/www/vendor ./app
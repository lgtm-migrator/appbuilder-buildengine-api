#!/usr/bin/env bash

# Run database migrations
whenavail db 3306 100 /data/yii migrate --interactive=0
whenavail db 3306 100 /data/yii migrate --interactive=0 --migrationPath=console/migrations-test

# Run codeception tests
cd /data
composer install --prefer-dist --no-interaction
./vendor/bin/codecept run unit

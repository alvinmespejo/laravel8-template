#!/usr/bin/env bash

# Get .env file from AWS SSM
cd /var/www/cloudcasts.io
aws --region ap-southeast-1 ssm get-parameter --with-decryption --name /cloudcasts/stg/env --output text --query 'Parameter.Value' > .env 

# Set permissions
sudo chown -R ubuntu:www-data /var/www/cloudcasts.io
sudo chmod -R 775 /var/www/cloudcasts.io/storage
sudo chmod -R 775 /var/www/cloudcasts.io/bootstrap/cache

# Below conditional syntax from here:
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
# Env var available for appspec hooks:
# https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#reference-appspec-file-structure-environment-variable-availability

# Reload php-fpm (clear opcache) if a web server
if [[ "$DEPLOYMENT_GROUP_NAME" == *"http"* ]]; then
    service php8.0-fpm reload
fi

# Start supervisor jobs (if supervisor is used)
if [[ "$DEPLOYMENT_GROUP_NAME" == *"queue"* ]]; then
    supervisorctl start all
fi

# sudo -u ubuntu php artisan migrate --force
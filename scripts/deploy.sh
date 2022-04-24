#!/usr/bin/env bash

# AWS CLI
# https://docs.aws.amazon.com/cli/latest/reference/deploy/create-deployment.html

DEPLOY_ENV="nah"

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/main" ]]; then
    DEPLOY_ENV="staging"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "tag/"* ]]; then
    DEPLOY_ENV="production"
fi

if [[ "$DEPLOY_ENV" != "nah" ]]; then
    # Deploy web servers
    aws --region ap-southeast-1 deploy create-deployment \
        --application-name cloudcasts-$DEPLOY_ENV-deploy-app \
        --deployment-group-name "cloudcasts-$DEPLOY_ENV-http-deploy-group" \
        --description "Deploying tag $CODEBUILD_WEBHOOK_TRIGGER" \
        --s3-location "bucket=cloudcasts-artifacts-codebuild,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"

    # Deploy queues
    aws --region ap-southeast-1 deploy create-deployment \
        --application-name cloudcasts-$DEPLOY_ENV-deploy-app \
        --deployment-group-name "cloudcasts-$DEPLOY_ENV-queue-deploy-group" \
        --description "Deploying tag $CODEBUILD_WEBHOOK_TRIGGER" \
        --s3-location "bucket=cloudcasts-artifacts-codebuild,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"
fi
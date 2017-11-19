#!/bin/bash
set -ex

# use shortform git hash as version
VERSION=$(git show -s --format=%h)

pip install awscli # install aws cli
pip install sceptre # install sceptre cli

# docker login using AWS env vars
eval $(aws ecr get-login --region us-east-1 --no-include-email)

# build, tag, push API
docker build -t concept-to-clinic/api:$VERSION --file ./compose/interface/Dockerfile-api .
docker tag concept-to-clinic/api:$VERSION 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-api:$VERSION
docker push 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-api:$VERSION

# build, tag, push  UI
docker build -t concept-to-clinic/ui:$VERSION --file ./compose/interface/Dockerfile-vue .
docker tag concept-to-clinic/ui:$VERSION 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-ui:$VERSION
docker push 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-ui:$VERSION

# build, tag, push prediction
docker build -t concept-to-clinic/prediction:$VERSION --file ./compose/prediction/Dockerfile .
docker tag concept-to-clinic/prediction:$VERSION 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-prediction:$VERSION
docker push 113913174193.dkr.ecr.us-east-1.amazonaws.com/c2c-prediction:$VERSION

# deploy to AWS
sceptre --dir 'deploy/' --var "ImageVersion=$VERSION" update-stack dev c2c
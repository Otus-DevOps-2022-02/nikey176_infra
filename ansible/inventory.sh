#!/bin/bash
ANSIBLE_DIR=/srv/otus/nikey176_infra/ansible
TERRAFORM_DIR=/srv/otus/nikey176_infra/terraform

APP_SERVER_STAGE=`terraform -chdir=$TERRAFORM_DIR/stage/ show -json | jq '.values.outputs.external_ip_address_app.value'`
DB_SERVER_STAGE=`terraform -chdir=$TERRAFORM_DIR/stage/ show -json | jq '.values.outputs.external_ip_address_db.value'`
APP_SERVER_PROD=`terraform -chdir=$TERRAFORM_DIR/prod/ show -json | jq '.values.outputs.external_ip_address_app.value'`
DB_SERVER_PROD=`terraform -chdir=$TERRAFORM_DIR/prod/ show -json | jq '.values.outputs.external_ip_address_db.value'`

cd $ANSIBLE_DIR
echo "{\"stage\":{\"hosts\":{\"app-stage\":{\"ansible_host\":$APP_SERVER_STAGE},\"db-stage\":{\"ansible_host\":$DB_SERVER_STAGE}}},\"prod\":{\"hosts\":{\"app-prod\":{\"ansible_host\":$APP_SERVER_PROD},\"db-prod\":{\"ansible_host\":$DB_SERVER_PROD}}},\"app\":{\"hosts\":{\"app-stage\":{\"ansible_host\":$APP_SERVER_STAGE},\"app-prod\":{\"ansible_host\":$APP_SERVER_PROD}}},\"db\":{\"hosts\":{\"db-stage\":{\"ansible_host\":$DB_SERVER_STAGE},\"db-prod\":{\"ansible_host\":$DB_SERVER_PROD}}}}" | jq > inventory.json
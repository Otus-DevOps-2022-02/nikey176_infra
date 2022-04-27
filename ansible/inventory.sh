#!/bin/bash
echo 'Собираем информацию...'

ANSIBLE_DIR=.
STAGE_DIR=$ANSIBLE_DIR/environments/stage
PROD_DIR=$ANSIBLE_DIR/environments/prod
TERRAFORM_DIR=../terraform

APP_SERVER_STAGE=`terraform -chdir=$TERRAFORM_DIR/stage/ show -json | jq '.values.outputs.external_ip_address_app.value'`
DB_SERVER_STAGE=`terraform -chdir=$TERRAFORM_DIR/stage/ show -json | jq '.values.outputs.external_ip_address_db.value'`
APP_SERVER_PROD=`terraform -chdir=$TERRAFORM_DIR/prod/ show -json | jq '.values.outputs.external_ip_address_app.value'`
DB_SERVER_PROD=`terraform -chdir=$TERRAFORM_DIR/prod/ show -json | jq '.values.outputs.external_ip_address_db.value'`

stage(){
cd $STAGE_DIR
echo "{\"stage\":{\"hosts\":{\"app-stage\":{\"ansible_host\":$APP_SERVER_STAGE},\"db-stage\":{\"ansible_host\":$DB_SERVER_STAGE}}},\"app\":{\"hosts\":{\"app-stage\":{\"ansible_host\":$APP_SERVER_STAGE}}},\"db\":{\"hosts\":{\"db-stage\":{\"ansible_host\":$DB_SERVER_STAGE}}}}" | jq > inventory.json
}

prod(){
cd $PROD_DIR
echo "{\"prod\":{\"hosts\":{\"app-prod\":{\"ansible_host\":$APP_SERVER_PROD},\"db-prod\":{\"ansible_host\":$DB_SERVER_PROD}}},\"app\":{\"hosts\":{\"app-prod\":{\"ansible_host\":$APP_SERVER_PROD}}},\"db\":{\"hosts\":{\"db-prod\":{\"ansible_host\":$DB_SERVER_PROD}}}}" | jq > inventory.json
}

read -p "Готово!

Выберите окружение:
1 - stage
2 - prod
" env

if [ "$env" == 1 ]
then
  stage
  echo "Файл $STAGE_DIR/inventory.json готов"
elif [ "$env" == 2 ]
then
  prod
  echo "Файл $PROD_DIR/inventory.json готов"
else
  echo "Неверное окружение"
fi

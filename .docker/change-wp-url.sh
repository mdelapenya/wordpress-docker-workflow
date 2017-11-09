#!/bin/bash

ENVIRONMENT="${1-local}"

function prop {
    grep "${1}" "$HOME/.workflow.properties" | cut -d'=' -f2
}

function checkWorkflow() {
	propsFile="$HOME/.workflow.properties"

	if [ -f "$propsFile" ]
	then
		echo "$propsFile found."
	else
		echo "$propsFile not found. Exiting"

		exit 1
	fi
}

checkWorkflow

DATABASE_NAME=$(prop 'DATABASE_NAME')
DOMAIN=$(prop 'DOMAIN')

if [ "$ENVIRONMENT" = "local" ]; then
	sed -i -- "s/http:\/\/www\.${DOMAIN}\.com/http:\/\/localhost/g" /app/${DATABASE_NAME}.sql
	sed -i -- "s/http:\/\/dev\.${DOMAIN}\.com/http:\/\/localhost/g" /app/${DATABASE_NAME}.sql
	sed -i -- "s/\/var\/www\/vhosts\/${DOMAIN}\.com\/dev\.${DOMAIN}\.com/\/app/g" /app/${DATABASE_NAME}.sql
	sed -i -- "s/\/var\/www\/vhosts\/${DOMAIN}\.com/\/app/g" /app/${DATABASE_NAME}.sql
elif [ "$ENVIRONMENT" = "staging" ]; then
	sed -i -- "s/http:\/\/www\.${DOMAIN}\.com/http:\/\/dev\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/http:\/\/localhost/http:\/\/dev\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/\/app/\/var\/www\/vhosts\/${DOMAIN}\.com\/dev\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/\/var\/www\/vhosts\/${DOMAIN}\.com/\/var\/www\/vhosts\/${DOMAIN}\.com\/dev\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
else
	sed -i -- "s/http:\/\/localhost/http:\/\/www\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/http:\/\/dev\.${DOMAIN}\.com/http:\/\/www\.${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/\/var\/www\/vhosts\/${DOMAIN}\.com\/dev\.${DOMAIN}\.com/\/var\/www\/vhosts\/${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
	sed -i -- "s/\/app/\/var\/www\/vhosts\/${DOMAIN}\.com/g" ./${DATABASE_NAME}.sql
fi

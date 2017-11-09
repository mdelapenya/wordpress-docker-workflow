#!/bin/bash

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
DATABASE_USERNAME=$(prop 'DATABASE_USERNAME')
DATABASE_PASSWORD=$(prop 'DATABASE_PASSWORD')

mysql -uadmin -p$MYSQL_PASS -e "CREATE DATABASE ${DATABASE_NAME} CHARACTER SET UTF8"
mysql -uadmin -p$MYSQL_PASS -e "GRANT ALL ON ${DATABASE_NAME}.* TO ${DATABASE_USERNAME}@localhost IDENTIFIED BY '${DATABASE_PASSWORD}'"

if [ -f /app/${DATABASE_NAME}.sql ]
then
    mysql -uadmin -p$MYSQL_PASS ${DATABASE_NAME} < /app/${DATABASE_NAME}.sql
fi

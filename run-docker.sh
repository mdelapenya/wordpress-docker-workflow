#!/bin/bash

function prop {
    grep "${1}" "./.workflow.properties" | cut -d'=' -f2
}

function checkWorkflow() {
	propsFile=".workflow.properties"

	if [ -f "$propsFile" ]
	then
		echo "$propsFile found."
	else
		echo "$propsFile not found. Exiting"

		exit 1
	fi
}

checkWorkflow

DOCKER_USER=$(prop 'DOCKER_USER')
DOCKER_IMAGE_NAME=$(prop 'DOCKER_IMAGE_NAME')
DOCKER_CONTAINER_NAME=$(prop 'DOCKER_CONTAINER_NAME')

docker build -t ${DOCKER_USER}/${DOCKER_IMAGE_NAME} .

docker rm -f ${DOCKER_CONTAINER_NAME} || true

docker run --name ${DOCKER_CONTAINER_NAME} \
	-v $(pwd)/wp-content:/app/wp-content \
	-d -p 80:80 \
	-e MYSQL_PASS="my-password" \
	-p 3306:3306 \
	${DOCKER_USER}/${DOCKER_IMAGE_NAME}

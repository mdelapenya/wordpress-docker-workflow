#!/bin/bash

set -o errexit

readonly ENV_STAGING="staging"
readonly ENV_PRODUCTION="production"

deploy() {
	BRANCH=${1}
	ENVIRONMENT=${2}

	git stash

	git checkout dev

	git rebase master

	git checkout ${BRANCH}

	git merge dev

	git_ftp_push ${ENVIRONMENT}

	git push origin ${BRANCH}

	git checkout dev

	git push origin dev

	git stash pop || true
}

deploy_to_staging() {
	deploy "staging" "${ENV_STAGING}"
}

deploy_to_production() {
	deploy "master" "${ENV_PRODUCTION}"

	VERSION=$(cat blog-version.txt)

	git tag "$VERSION" || true

	git push origin --tags
}

git_ftp_push() {
	echo "Uploading files to ${1}"
	git ftp push -s ${1}
}

main() {
	case $1 in
	all)
		deploy_to_staging
		deploy_to_production
		;;

	production)
		deploy_to_production
		;;

	staging)
		deploy_to_staging
		;;

	*)
		echo "Error:
	Unknown environment ${1}.
	Usage: publish.sh [staging|production|all]

	Aborting."
		exit 1
		;;

	esac
}

main "$@"

COMPOSE = docker-compose
COMPOSE_RUN = ${COMPOSE} run --rm --remove-orphans
COMPOSE_RUN_TARGET = ${COMPOSE_RUN} $@

.PHONY: help
help:		## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: alpine
alpine: 	## Test Read/Write to local filesystem
	${COMPOSE_RUN_TARGET} sh -c "mkdir .dir"
	${COMPOSE_RUN_TARGET} sh -c "touch .dir/.file"
	${COMPOSE_RUN_TARGET} sh -c "rm -rf .dir"

.PHONY: aws
aws: 		## Test AWS CLI
	${COMPOSE_RUN} aws --version

.PHONY: gradle
gradle:		## Test Gradle CLI
	${COMPOSE_RUN_TARGET} gradle -version

.PHONY: java
java:		## Test Java
	${COMPOSE_RUN_TARGET} javac -version

.PHONY: k8s
k8s:		## Test k8s
	${COMPOSE_RUN_TARGET} kubectl version --client=true

.PHONY: terraform
terraform:	## Test Terraform CLI
	${COMPOSE_RUN} terraform --version

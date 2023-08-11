# Prevent default echo of commands and "[target] is up to date" messages
.SILENT:

# NOTE .PHONY denotes that the target does _not_ correspond to any local file of the same name (true of all our targets)
.PHONY: $(MAKECMDGOALS)

# These just enable reuse and single-place modification of common commands
COMPOSE = docker compose
COMPOSE_RUN = ${COMPOSE} run -u $$(id -u):$$(id -g) --rm --remove-orphans
COMPOSE_RUN_TARGET = ${COMPOSE_RUN} $@

help:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

alpine:     ## Test Read/Write to local filesystem
	${COMPOSE_RUN_TARGET} sh -c "mkdir .dir"
	${COMPOSE_RUN_TARGET} sh -c "touch .dir/.file"
	${COMPOSE_RUN_TARGET} sh -c "rm -rf .dir"

aws:        ## Test AWS CLI
	${COMPOSE_RUN} aws --version

gradle:     ## Test Gradle CLI
	${COMPOSE_RUN_TARGET} gradle -version

java:       ## Test Java
	${COMPOSE_RUN_TARGET} javac -version

k8s:        ## Test k8s
	${COMPOSE_RUN_TARGET} kubectl version --client=true

terraform:  ## Test Terraform CLI
	${COMPOSE_RUN} terraform --version

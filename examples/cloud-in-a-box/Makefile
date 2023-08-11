# This line includes the .env file environment vars (if present, otherwise it's ignored)
-include .env

# These just enable reuse and single-place modification of common commands
COMPOSE = docker compose -p cloud_in_a_box
COMPOSE_RUN = ${COMPOSE} run --rm

# NOTE this setting requires Docker Compose v2 to work
export COMPOSE_IGNORE_ORPHANS = True

# Prevent default echo of commands and "[target] is up to date" messages
.SILENT:

# NOTE .PHONY denotes that the target does _not_ correspond to any local file of the same name (true of all our targets)
.PHONY: $(MAKECMDGOALS)

# This parses additional arguments beyond the target and stores them in a variable for later use
CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

##Welcome to the Cloud-in-a-Box Toolkit 🛠️
##
##The targets/commands below can be ran via `make <target>` (e.g. `make help`).
##
##Some commands (like `terraform`) accept additional arguments so you can run things like:
##  `make terraform plan`
##  `make -- terraform --help`  # Note the extra `--` that's needed to keep make from processing the `--help` argument
##  `make aws sts get-caller-identity`
##
##  See the README.md in this directory for a guided tour of this example.  Happy Clouding! ☁️
##

help:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

localstack: ## Start localstack (Pro)
	${COMPOSE} -f localstack-compose.yaml up

terraform:  ## Run a terraform command
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   terraform $(CMD_ARGS)

awslocal:   ## Run an aws CLI command against LocalStack (set the LOCALSTACK_ENDPOINT envar via the .env file etc.)
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   aws --endpoint-url=${LOCALSTACK_ENDPOINT} $(CMD_ARGS)

kubectl:    ## Run a k8s tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   k8s kubectl --kubeconfig kube.config $(CMD_ARGS)

k9s-build:  ## Build the customized k9s kubernetes (CLI) management tool container image
	${COMPOSE} build k9s

k9s:        ## Run the k9s kubernetes (CLI) management tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   k9s --kubeconfig kube.config

shell:      ## Obtain a shell in the given compose service / container (e.g. `make shell aws`)
	${COMPOSE_RUN} --entrypoint /bin/sh $(CMD_ARGS)

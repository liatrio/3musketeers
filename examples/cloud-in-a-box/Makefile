# This line includes the .env file environment vars (if present, otherwise it's ignored)
-include .env

# These just enable reuse and single-place modification of common commands
COMPOSE = docker compose -p cloud_in_a_box
COMPOSE_RUN = ${COMPOSE} run -u $$(id -u):$$(id -g) --env HOME="." --env USER=$${USER} --rm

# NOTE this setting requires Docker Compose v2 to work
export COMPOSE_IGNORE_ORPHANS = True

# Prevent default echo of commands and "[target] is up to date" messages
.SILENT:

# NOTE .PHONY denotes that the target does _not_ correspond to any local file of the same name (true of all our targets)
.PHONY: $(MAKECMDGOALS)

# Extract first target passed to make
CMD := $(wordlist 1,1,$(MAKECMDGOALS))

# This parses additional arguments beyond the first target and stores them in a variable for later use
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

help:			## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

# Don't define any targets if we're just trying to invoke a shell on a compose service (avoids make redefine warnings)
ifneq ($(CMD),shell)

prep:			## Do some preperation - pull docker images we need in later steps
	docker pull hashicorp/terraform:1.5
	docker pull amazon/aws-cli:2.13.8
	docker pull alpine/k8s:1.27.4
	docker pull alpine:3.18.3
	docker pull gradle:jdk17-focal
	docker pull eclipse-temurin:17.0.8_7-jdk-jammy
	docker pull public.ecr.aws/nginx/nginx:1.23
	docker pull localstack/localstack-pro:2.2

localstack:		## Start localstack (Pro)
	${COMPOSE} -f localstack-compose.yaml up

tf-up:		## tf apply to bring up the k8s stack
	make terraform init && make -- terraform apply -auto-approve

terraform:		## Run a terraform command
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   terraform $(CMD_ARGS)

awslocal:		## Run an aws CLI command against LocalStack (set the LOCALSTACK_ENDPOINT envar via the .env file etc.)
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   aws --endpoint-url=${LOCALSTACK_ENDPOINT} $(CMD_ARGS)

kubectl:		## Run a k8s tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   k8s kubectl --kubeconfig kube.config $(CMD_ARGS)

k9s-build:		## Build the customized k9s kubernetes (CLI) management tool container image
	${COMPOSE} build k9s

k9s:			## Run the k9s kubernetes (CLI) management tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=us-west-2 \
                   --env AWS_ACCESS_KEY_ID=access_key \
                   --env AWS_SECRET_ACCESS_KEY=secret_key \
                   k9s --kubeconfig kube.config

down:			## Stop localstack and related containers
	${COMPOSE} -f localstack-compose.yaml down
	${COMPOSE} down

clean:			## Remove local volume folder contents
	echo
	echo "remove k3d containers and volumes that sometimes get stuck (may error if they don't exist)..."
	-docker rm -f $(shell docker ps -aq --filter 'name=k3d-terraform-testing-')
	-docker volume rm -f $(shell docker volume ls -q --filter "name=k3d-terraform-testing-")

	echo
	echo "remove LocalStack volume..."
	rm -rf volume/*
	
	echo
	echo "remove Terraform files..."
	rm -f terraform.tfstate*
	rm -f .terraform.lock.hcl
	
	echo
	echo "[done cleaning]"

	echo
	echo [files you can manually delete if you like]
	echo "rm -rf .terraform"
	echo "rm -rf .terraform.d"
	echo

get-cluster-name:	## Get the k8s cluster name
	make -- awslocal eks list-clusters --query 'clusters[0]'

cluster-status:		## Check the status of the k8s cluster
	make -- awslocal eks update-kubeconfig --name $(CMD_ARGS) --kubeconfig kube.config

check:			## Check your docker containers, images, network etc
	echo "containers..."
	docker ps -a
	echo "\nvolumes..."
	docker volume ls
	echo "\nvolume folder ./volume"
	ls -la volume/
	echo "\nimages..."
	docker images
	echo "\nnetwork..."
	docker network ls

endif

shell:			## Obtain a shell in the given compose service / container (e.g. `make shell aws`)
	${COMPOSE_RUN} --entrypoint /bin/sh $(CMD_ARGS) && exit

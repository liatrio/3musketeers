# TODO update this text and update top-level Makefile so `make help terraform` dumps #@-prefixed text
#@
#@Some commands (like `terraform`) accept additional arguments so you can run things like:
#@  `make terraform plan`
#@  `make -- terraform --help`  # Note the extra `--` that's needed to keep make from processing the `--help` argument
#@  `make aws sts get-caller-identity`
#@
#@  See the README.md in this directory for a guided tour of this example.  Happy Clouding! ☁️
terraform: ## Run a terraform command
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   terraform $(CMD_ARGS)
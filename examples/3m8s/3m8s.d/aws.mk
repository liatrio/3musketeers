aws: ## Run an aws CLI command
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   aws $(CMD_ARGS)
k8s: ## Run a k8s tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   k8s $(CMD_ARGS)
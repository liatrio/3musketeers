k9s-build: ## Build the customized k9s container image
	${COMPOSE} build k9s

k9s: k9s-build ## Run the k9s kubernetes (CLI) management tool
	${COMPOSE_RUN} --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
				   --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
				   --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
				   --env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
                   k9s $(CMD_ARGS)
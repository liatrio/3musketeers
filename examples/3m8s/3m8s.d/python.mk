python-build: ## Build the customized python container image
	${COMPOSE} build python

python: python-build ## Run commands in the python environment (e.g. make -- python poetry --version)
	${COMPOSE_RUN} --env MY_ENVAR= \
                   python $(CMD_ARGS)

default: help

# generate list of compose file snippets from plugins dir
COMPOSE_FILES:=$(wildcard 3m8s.d/*.yaml)
# create compose file path from default compose file and snippets (converting to : separated PATH style entries)
export COMPOSE_FILE = compose.yaml:$(shell echo $(COMPOSE_FILES) | sed 's/ /:/g')

# ---
# TODO `make help terraform` should dump a long help directly from the `terraform.mk` file
# TODO `make help` should show enabled and disabled targets differently (use colorized approach from other Makefile)
# ---

# Colors and Emojis
COLOR_RESET = \033[0m
COLOR_RED = \033[31m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

EMOJI_CHECKMARK = "✅"
EMOJI_TADA = "🎉"

# TODO still needed? 👇
# This line includes the .env file environment vars (if present, otherwise it's ignored)
-include .env

# Define common commands
COMPOSE = docker compose -p 3m8s
# NOTE we're using the current user's UID:GID and $HOME in the container context
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

IMAGES := $(shell grep -h 'image' $(COMPOSE_FILES) | sed 's/image: //')

# TODO add doc snippets to each Makefile and processing to display them
## 3Musketeers (3m8s) Toolkit 🛠️
## The targets/commands below can be ran via `make <target>` (e.g. `make help`).

# Don't define any targets if we're just trying to invoke a shell on a compose service (avoids make redefine warnings)
ifneq ($(CMD),shell)
-include $(wildcard 3m8s.d/*.mk)
endif

help: ## Show this help
	# Display header
	@awk 'BEGIN {FS = "^## "} /^## .*/ {printf "${COLOR_BLUE}%-1s${COLOR_RESET}\n", $$2}' $(MAKEFILE_LIST)
	# Display targets
	@awk 'BEGIN {FS = ":.*?## "} \
		/^[a-zA-Z_-]+:.*?## / {printf "${COLOR_GREEN}%-30s${COLOR_RESET}%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

alias: ## Shell alias help
	@echo Copy and paste the following into your shell to enable commands like \'make plugin --version\' to work \
			without having to type \'make --\'
	@echo alias make=\"make --\"

pull: ## Pull all enabled plugin images
	@echo "${COLOR_YELLOW}Pulling all container images${COLOR_RESET}"
	for image in $(IMAGES); do \
  		echo "${COLOR_BLUE}Pulling image $${image}${COLOR_RESET}" ;\
  		docker pull $${image} ;\
  		echo ${EMOJI_CHECKMARK} ;\
  	done
	@echo "${COLOR_YELLOW}All images pulled ${COLOR_RESET}${EMOJI_TADA}"

shell: ## Obtain a shell in the given compose service / container (e.g. `make shell aws`)
	${COMPOSE_RUN} --entrypoint /bin/sh $(CMD_ARGS) && exit

debug: ## Dump some debugging info
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "COMPOSE_FILES: $(COMPOSE_FILES)"
	@echo "COMPOSE_FILE: $(COMPOSE_FILE)"

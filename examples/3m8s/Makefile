default: help

VERSION := "0.0.1-RC"

# generate list of compose file snippets from plugins dir
COMPOSE_FILES := $(wildcard 3m8s.d/*.yaml)
# create compose file path from default compose file and snippets (converting to : separated PATH style entries)
export COMPOSE_FILE := $(shell echo $(COMPOSE_FILES) | sed 's/ /:/g')

# ---
# TODO `make help terraform` should dump a long help directly from the `terraform.mk` file
# TODO version plugins
# TODO add ability to "install" plugin files from the repo (download via curl/wget to 3m8s.d dir)
#  e.g. `make install aws` would download and install the aws plugin if not already installed
# ---

# Colors and Emojis
COLOR_RESET := \033[0m
COLOR_RED := \033[31m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

EMOJI_CHECKMARK := "✅"
EMOJI_TADA := "🎉"

# TODO still needed? 👇
# This line includes the .env file environment vars (if present, otherwise it's ignored)
-include .env

# Define common commands
COMPOSE := docker compose -p 3m8s
# NOTE we're using the current user's UID:GID and $HOME in the container context
COMPOSE_RUN := ${COMPOSE} run -u $$(id -u):$$(id -g) --env HOME="." --env USER=$${USER} --rm --service-ports

# NOTE this setting requires Docker Compose v2 to work
export COMPOSE_IGNORE_ORPHANS := True

# Prevent default echo of commands and "[target] is up to date" messages
.SILENT:

# NOTE .PHONY denotes that the target does _not_ correspond to any local file of the same name (true of all our targets)
.PHONY: $(MAKECMDGOALS)

# Extract first target passed to make
TARGET := $(wordlist 1,1,$(MAKECMDGOALS))

# Extract first argument to target
ARG := $(wordlist 2,2,$(MAKECMDGOALS))

# Collect all arguments after target
CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Plugin files (used only if `plugin` target is invoked but defined here to avoid $(eval)
PLUGIN_MAKEFILE := "3m8s.d/$(ARG).mk"
PLUGIN_COMPOSE_FILE := "3m8s.d/$(ARG).yaml"

# Obtain list of container images defined in plugin Compose YAML files (if any exist)
ifneq ($(strip $(COMPOSE_FILES)),)
IMAGES := $(shell grep -h 'image' $(COMPOSE_FILES) | sed 's/image: //')
endif

# Ensure the 3m8s.d dir exists
ifeq ($(shell test -d 3m8s.d && echo exists),exists)
else
$(info "3m8s.d not found...creating")
$(shell mkdir 3m8s.d)
endif

## 3Musketeers (3m8s) Toolkit 🛠️
## The targets/commands below can be ran via `make <target>` (e.g. `make help`).

# Don't define any targets if we're just trying to invoke a shell on a compose service (avoids make redefine warnings)
ifneq ($(TARGET),shell)
-include $(wildcard 3m8s.d/*.mk)
endif

alias: ## Shell alias help
	@echo "Copy and paste the following into your shell to enable commands like 'make aws --version' to work \
			without having to type 'make --' (put in your shell startup file to make permanent):\n"
	@echo 'alias make="make --"'

debug: ## Dump some debugging info
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "COMPOSE_FILES: $(COMPOSE_FILES)"
	@echo "COMPOSE_FILE: $(COMPOSE_FILE)"

help: ## Show this help
	# Display header
	@awk 'BEGIN {FS = "^## "} /^## .*/ {printf "${COLOR_BLUE}%-1s${COLOR_RESET}\n", $$2}' $(MAKEFILE_LIST)
	# Display targets
	@awk 'BEGIN {FS = ":.*?## "} \
		!/\s*@.*/ && /:.*?## / {printf "${COLOR_GREEN}%-30s${COLOR_RESET}%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

plugin: ## Generate plugin scaffolding (e.g. `make plugin node`)
	@if [ -z $(ARG) ]; then \
		echo "Plugin name required! (e.g. 'make plugin some-name')";\
		exit 1;\
	fi

	@if [ -f $(PLUGIN_MAKEFILE) ]; then \
		echo "Plugin Makefile $(PLUGIN_MAKEFILE) already exists (not overwriting!)";\
		exit 1;\
	fi

	@echo "Generating Makefile $(PLUGIN_MAKEFILE) for $(ARG) plugin..."
	@echo "$(ARG): ## $(COLOR_YELLOW)TODO Add one-line description$(COLOR_RESET)\n\
	\t\$${COMPOSE_RUN} --env MY_ENVVAR=${SOME_SHELL_ENVAR} \
	$(ARG) \$$(CMD_ARGS)" > 3m8s.d/$(ARG).mk
	@echo "$(EMOJI_TADA) Done!"

	@if [ -f $(PLUGIN_COMPOSE_FILE) ]; then \
		echo "Plugin Compose file $(PLUGIN_COMPOSE_FILE) already exists (not overwriting!)";\
		exit 1;\
	fi

	@echo "Generating Compose file $(PLUGIN_COMPOSE_FILE) for $(ARG) plugin..."
	@echo "services:\n\
	  $(ARG):\n\
	    image: hello-world:latest # TODO Set your namespace/image:version\n\
	    volumes:\n\
	      - ..:/var/opt/app\n\
	    working_dir: /var/opt/app\n\
	    ports: # TODO Add port mappings here (container:host)\n\
	      - 80:8080" > 3m8s.d/$(ARG).yaml
	@echo "$(EMOJI_TADA) Done!"

pull: ## Pull all enabled plugin images
	@echo "${COLOR_YELLOW}Pulling all container images${COLOR_RESET}"
	for image in $(IMAGES); do \
  		echo "${COLOR_BLUE}Pulling image $${image}${COLOR_RESET}" ;\
  		docker pull $${image} ;\
  		echo ${EMOJI_CHECKMARK} ;\
  	done
	@echo "${COLOR_YELLOW}All images pulled ${COLOR_RESET}${EMOJI_TADA}"

shell: ## Launch a shell in the given target (e.g. `make shell aws`)
	${COMPOSE_RUN} --entrypoint /bin/sh $(CMD_ARGS) && exit

version: ## Display 3Musketeers Toolkit version
	@echo $(VERSION)

# The ONE Portable Integrated Environment Containerized Engine 🏴‍☠️⚓️
VERSION := "0.0.1-RC"

# If the user doesn't provide any targets, show help
ifeq ($(MAKECMDGOALS),)
default: help
endif

# generate list of compose file snippets from plugins dir
COMPOSE_FILES := $(wildcard 3m8s.d/*.yaml)
# create compose file path from default compose file and snippets (converting to : separated PATH style entries)
export COMPOSE_FILE := $(shell echo $(COMPOSE_FILES) | sed 's/ /:/g')

# ---
# TODO `make help terraform` should dump a long help directly from the `terraform.mk` file
# TODO version plugins
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

# Hide orphan warning message
# NOTE this setting requires Docker Compose v2 to work
export COMPOSE_IGNORE_ORPHANS := True

# Prevent default echo of commands and "[target] is up to date" messages
.SILENT:

# Tell make that whatever targets the user requested shouldn't be correlated with any local file's existence or status
.PHONY: $(MAKECMDGOALS)

# Extract first target passed to make
TARGET := $(wordlist 1,1,$(MAKECMDGOALS))
# Extract first argument to target
ARG := $(wordlist 2,2,$(MAKECMDGOALS))
# Collect all arguments after target (including the first)
CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Plugin files (used only if `plugin` target is invoked but defined here to avoid call $(eval) fxn) 👿
PLUGIN_MAKEFILE := "3m8s.d/$(ARG).mk"
PLUGIN_COMPOSE_FILE := "3m8s.d/$(ARG).yaml"
PLUGIN_DOWNLOAD_BASE := "https://github.com/liatrio/3musketeers/raw/main/examples/3m8s/3m8s.d/"

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

# TODO Prevent built-in 'help' target from running when user runs `make aws help`
# TODO cleanup rearranged targets which resolved `make terraform version` issue where `make version` would also run

# TODO explain the block below and mark the start/end of conditionals (or try nesting them)
BUILTIN_TARGETS := alias debug install plugin pull shell version
# If the requested TARGET is not a built-in, include plugin files to check them for valid targets
ifeq (,$(filter $(TARGET),$(BUILTIN_TARGETS)))
-include $(wildcard 3m8s.d/*.mk)

# Generate a list of plugin targets (plus 'help' which needs plugins included to work properly)
# TODO use append here (PLUGIN_TARGETS := help, then PLUGIN_TARGETS += help $(shell... (eliminates conditional block)
ifneq ($(wildcard 3m8s.d/*.mk),)
PLUGIN_TARGETS := help $(shell grep -h '^[^.%][-a-zA-Z0-9]*:' 3m8s.d/*.mk | cut -d ':' -f 1)
# If we don't have any plugins installed, just include help
else
PLUGIN_TARGETS := help
endif

# If the user requested a target, but it's not in the list of PLUGIN_TARGETS, prompt them to install it
ifeq (,$(filter $(TARGET), $(PLUGIN_TARGETS)))
.DEFAULT:
	[ -z $(TARGET) ] || echo "Target '$(TARGET)' not defined.  Do you need to 'make install $(TARGET)'?";
endif

# User requested a built-in target, define and let make handle
else
alias: ## Shell alias help
	@echo "Copy and paste the following into your shell to enable commands like 'make aws --version' to work \
			without having to type 'make --' (put in your shell startup file to make permanent):\n"
	@echo 'alias make="make --"'

debug: ## Dump some debugging info
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "COMPOSE_FILES: $(COMPOSE_FILES)"
	@echo "COMPOSE_FILE: $(COMPOSE_FILE)"

install: ## Install a plugin (e.g. `make install aws`)
	# TODO 'make uninstall' (remove 3m8s.d/$(ARG).*
	# TODO use a list (mk, yaml, Dockerfile) (maybe even a manifest in the main repo listing plugin files)
	# TODO handle case where plugin already installed (prompt user?)
	#  Need this to be able to list remote plugins too (an index file).  Once this is in, remove the curl -f and just
	#  iterate over the list in the manifest (don't need to explicitly list each file)
	#  `make plugin` needs to generate the manifest and instructions also
	@if [ -z $(ARG) ]; then \
		echo "Plugin name required! (e.g. 'make install aws')";\
		exit 1;\
	fi

	# Download plugin files with curl or ask user to install it
	#  - fail silently if Dockerfile not present since not all plugins will have one (NOTE this also prevents the
	#	 progress bar from showing)
	@ if which curl >/dev/null 2>&1; then \
   		echo "Downloading plugin files..."; \
   		cd 3m8s.d; \
   		curl --progress-bar -L -O "$(PLUGIN_DOWNLOAD_BASE)/$(ARG).mk"; \
   		curl --progress-bar -L -O "$(PLUGIN_DOWNLOAD_BASE)/$(ARG).yaml"; \
   		curl --progress-bar -fL -O "$(PLUGIN_DOWNLOAD_BASE)/$(ARG).Dockerfile" 2>/dev/null || true; \
   	else \
   	  	echo "Can't find 'curl'.  Please install it and try again."; \
   	  	exit 1; \
   	fi
	@echo "$(ARG) plugin installed! $(EMOJI_TADA)"

plugin: ## Generate plugin scaffolding (e.g. `make plugin node`)
	@if [ -z $(ARG) ]; then \
		echo "Plugin name required! (e.g. 'make plugin my-plugin')";\
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
	@if [ -z $(ARG) ]; then \
		echo "Plugin name required! (e.g. 'make shell aws')";\
		exit 1;\
	fi
	${COMPOSE_RUN} --entrypoint /bin/sh $(CMD_ARGS) && exit

version: ## Display 3Musketeers Toolkit version
	@echo $(VERSION)
endif

# Help will always be given to those who ask for it 🪄 (this target is _always_ defined)
help: ## Show this help
	# Display header
	@awk 'BEGIN {FS = "^## "} /^## .*/ {printf "${COLOR_BLUE}%-1s${COLOR_RESET}\n", $$2}' $(MAKEFILE_LIST)
	# Display targets
	@awk 'BEGIN {FS = ":.*?## "} \
		!/\s*@.*/ && /:.*?## / {printf "${COLOR_GREEN}%-30s${COLOR_RESET}%s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

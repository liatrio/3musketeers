# Three Mates (3m8s) Portable/Pluggable 3Musketeers 🤺⚔️🗡️
This example provides a portable `Makefile` that can be dropped into any project without modification for ⚡️ fast setup of 3Musketeers in any project. Tools needed to build and run the project are added via "plugins" in the project `3m8s.d` dir.

## Quickstart
1. Copy the `Makefile` to your project directory
2. Run `make` to check that your setup is correct and to create the `3m8s.d` dir if it doesn't exist (See [top-level README](../../README.md) for help setting up 3Musketeers)
3. Copy desired plugins from the [3m8s.d](./3m8s.d) dir here into your project's `3m8s.d` dir

That's it!  Run `make` for help with any plugins.

**`TIP`** Run `make alias` to generate a shell alias string which you can put in your startup files.  This alias will keep you from having to type `make --` when passing arguments to plugins (otherwise `make` tries to interpret the args itself).

## Customization
### Creating Plugins
If you need to create a plugin that doesn't exist, just run `make plugin <plugin_name>` to generate scaffold files and edit them from there.  See existing plugins for a guide.

### Docker Builds
See the [k9s.Dockerfile](3m8s.d/k9s.Dockerfile) and corresponding [k9s.mk](3m8s.d/k9s.mk) & [k9s.yaml](3m8s.d/k9s.yaml) files for an example using a custom Docker image.

## Cookbook
This section contains step-by-step guides for common use-cases.

### NodeJS Web App
1. Copy the `Makefile` to your project directory
   ```shell
   cp Makefile <your-project-dir>
   ```
2. Run `make` in your project dir
   ```shell
   cd <your-project-dir>
   make
   ```
3. Copy the `node` plugin file
   ```shell
   cp 3m8s.d/node.* <your-project-dir>/3m8s.d
   ```
4. Install dependencies
   ```shell
   cd <your-project-dir>
   make node npm install
   ```
5. Check the `3m8s.d/node.yaml` Docker Compose file `ports` entry and update if needed (exposes port 3000 by default)
   ```shell
   cd <your-project-dir>
   cat 3m8s.d/node.yaml
   # Modify the `ports` list as-needed for your app
   ```
6. Run `make node npm start`
   ```shell
   cd <your-project-dir>
   make node npm start
   ```
   
If you run into issues, you can run `make shell node` to launch a shell in the NodeJS environment for troubleshooting.

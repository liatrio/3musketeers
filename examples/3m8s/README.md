# Three Mates (3m8s) Portable/Pluggable 3Musketeers 🤺⚔️🗡️
This example provides a portable `Makefile` that can be dropped into any project without modification for ⚡️ fast setup of 3Musketeers in any project. Tools needed to build and run the project are added via "plugins" in the project's `3m8s.d` dir.

If you don't have 3Musketeers set up yet, see the [top-level README](../../README.md) for help.

## ⚡️ Quickstart
1. Copy [Makefile](Makefile) to your project directory
   ```shell
   wget https://raw.githubusercontent.com/liatrio/3musketeers/main/examples/3m8s/Makefile
   ```
3. Run `make install <plugin>` to install desired plugins into your project's `3m8s.d` dir

That's it!  Run `make` to see help for the newly installed plugins.  See this repo's [3m8s.d](3m8s.d) dir for available plugins.

**`TIP`** Run `make alias` to generate a _shell alias_ string which you can paste into your shell or put in your startup files.  This alias will keep you from having to type `make --` when passing arguments to plugins (otherwise `make` tries to interpret the args itself).

## ⚙️ Customization
### Creating Plugins
If you need to create a plugin that doesn't exist, just run `make plugin <plugin_name>` to generate scaffold files and edit them from there.  See existing plugins for a guide.  Consider contributing your plugin back to this project!  (See [CONTRIBUTING](CONTRIBUTING.md)).

### Docker Builds
See the [k9s.Dockerfile](3m8s.d/k9s.Dockerfile) and corresponding [k9s.mk](3m8s.d/k9s.mk) & [k9s.yaml](3m8s.d/k9s.yaml) files for an example using a custom Docker image.

## 👨‍🍳 Cookbook
This section contains step-by-step guides for common use-cases.

### NodeJS Web App
1. Copy the `Makefile` to your project directory
   ```shell
   cp Makefile <your-project-dir>
   ```
2. Install the `node` plugin (_from your project dir_)
   ```shell
   make install node
   ```
3. Install dependencies
   ```shell
   make node npm install
   ```
4. Check the `3m8s.d/node.yaml` Docker Compose file `ports` entry and update if needed (exposes port `3000` by default)
   ```shell
   cat 3m8s.d/node.yaml
   # Modify the `ports` list as-needed for your app
   ```
5. Run `make node npm start`
   ```shell
   cd <your-project-dir>
   make node npm start
   ```
   
If you run into problems, you can run `make shell node` to launch a shell in the NodeJS environment for troubleshooting.

## 💥 Troubleshooting
If you don't see your problem or fix below, [raise an issue in the repo](https://github.com/liatrio/3musketeers/issues/new/choose).

### Issues with `make install`
The `install` command downloads files from this public repo via `curl`. You can always copy plugin files directly from this repo's [3m8s.d](3m8s.d) dir into your project's `3m8s.d` dir if you have any issues.

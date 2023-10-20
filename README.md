# 3 Musketeers for Local Development
This project contains examples and tools for the [3 Musketeers](https://3musketeersdev.netlify.app/) pattern for Local Development.  It's recommended that you read up on the pattern at the official site if you're not already familiar with it to get some helpful context, and apply the pattern in a way that makes sense within your team and organization.

**Note:** The use of 3 Musketeers for Local Development is not an endorsement for using the pattern in CI/CD pipelines. How to create scalable CI/CD pipelines and templates with automated governance is out of scope for this repo and will depend on your organizaitons specific strategy for CI/CD at scale.

## Quickstart
You'll need an environment with the following tools.  For help setting those up, see the [Setup](#setup) section below.
<dl>
<dt>make</dt>
<dd>🧙 <a href="https://www.gnu.org/software/make/" target="_blank">Make</a> is a tool as old as time, install it with your favorite package manager if you don't already have it.</dd>
<dt>docker</dt>
<dd>🐳 <a href="https://www.docker.com/" target="_blank">Docker</a> is a popular container tool suite.  For 3 Musketeers we need the docker CLI and the ability to run container images locally.</dd>
<dt>docker compose</dt>
<dd>🎛️ <a href="https://docs.docker.com/compose/" target="_blank">Docker Compose</a> is a plugin for docker that enables the management of multiple services (you may already have this if you've installed Docker).</dd>
</dl>

That's it! 🏆

The whole point of the 3 Musketeers pattern is that with these 3 basic tools we can run just about anything _without_ having to install all the tooling directly on the host OS.  Instead, we run the tools in their own (usually already existing) container images and give them access to modify our local files to compile, test, etc. as usual.  This makes for a _very_ quick setup and improved portability across environments.

### check
✅ Next run the [check.sh](check.sh) script to see if you're setup is ready!

🛟 If you encounter any issues, check the output for error messages and see the [Troubleshooting](#troubleshooting) section for common problems/solutions.

#### What this script does...

The script will fetch several common tool images and run some commands for each.  In doing so, the script validates the following:
1. `make`, `docker`, and `docker compose` are installed and in your PATH
2. Public images from hub.docker.com can be pulled down
3. Those images can be ran locally, including the tools they provide
4. Read/Write access to the local filesystem is working

**`TIP`** You can run individual checks using the Makefile targets (e.g. `make alpine`).  Run `make` by itself for help.

Once you've got a working setup, you can start using the examples in this project and any other 3Musketeers based project! ⚔️

## Examples
In the [examples](examples) dir, you'll find an organized, curated set of example configurations to jump start your project or help with the migration of an existing project to 3 Musketeers.


## Setup

Skip to the section corresponding to your OS and follow the instructions there.

### 🧑‍💻 macOS

1. Install Homebrew
    [Homebrew](https://brew.sh/) is the canonical macOS package manager.  Follow the instructions at the website to install.
 
2. Check for `make`
    You probably already have `make`.  Open a terminal and run `make --version` to confirm.
 
    If you need to install make for some reason (or want the latest GNU make), run `brew install make` and follow any instructions provided by the installation script to finalize the setup.

3. Install [Docker](https://www.docker.com/)
    Install Docker Desktop (Community Edition) with `brew install --cask docker`.

    Try [Colima](https://github.com/abiosoft/colima#installation) if the Docker license is an issue.

   **`NOTE`** This guide assumes you have v2 of `docker compose` available (not the deprecated Python `docker-compose` package). If you are _not_ using Docker Desktop, you may need to create a symlink for Docker to find the plugin, e.g.
    ```
    mkdir -p ~/.docker/cli-plugins
    ln -sfn $HOMEBREW_PREFIX/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
    ```
   _Homebrew example, adapt as-needed_

4. If you installed Docker Desktop, you should already have Compose.  Run `docker compose --version` in a terminal to verify.

    If you need to install Compose separately, run `brew install docker-compose` or visit [Install Docker Compose](https://docs.docker.com/compose/install/) for other options.

🏁 All done!  Run the [Quickstart check script](#check) to validate your setup.

### 🪟 Windows

#### Optional (Recommended)
This software is optional, but _highly_ recommended for the best experience.

1. Visit the Microsoft Store to install [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701).  Use this terminal application instead of CMD.EXE or PowerShell when running WSL below.

#### WSL and `make`

1. Install the [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) (WSL) if you don't already have it.  Use the _Ubuntu_ distribution (this is typically the default distribution).  Open a WSL 2 terminal for the rest of the steps.

    **`NOTE`** Ensure you are using WSL v2  (See [Enabling Docker support in WLS 2 distros](https://docs.docker.com/desktop/wsl/#enabling-docker-support-in-wsl-2-distros) for steps to verify/upgrade).
 
    **`TIP`** Run `sudo apt-get update` now to be sure you have the latest package info for the install steps below.

2. Install `make` with `sudo apt install -y make`.  After installation, `make --version` should show the installed version.

#### Docker Desktop

1. Follow the steps in [Turn on Docker Desktop WSL 2](https://docs.docker.com/desktop/wsl/#turn-on-docker-desktop-wsl-2) to install Docker Desktop and set it to use WSL 2 as the runtime.  If you've already installed Docker Desktop via another method, confirm that WSL 2 is the engine configured for Docker.

2. Confirm you can run both `docker` and `docker compose` from a WSL 2 terminal.

---

If your environment involves a Windows VPN, proxy, or other "complex" configuration, see the [WSL](docs/WSL.md) doc for additional setup tips.

🏁 That's it!  Now you can run the [Quickstart check script](#check) to validate your setup.


## Troubleshooting

#### Makefile: *** multiple target patterns. Stop.
This can happen when passing complex arguments through to underlying tools via `make` due to characters that make tries to interpret directly.

To fix the issue, escape characters such as `:` like this:
```shell
make -- awslocal eks create-cluster \
     --name cluster1 \
     --role-arn "arn\:aws\:iam\:\:000000000000\:role/eks-role" \
     --resources-vpc-config "{}"
```

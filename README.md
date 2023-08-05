# 3 Musketeers
This project contains examples and tools for the 3 Musketeers (https://3musketeers.io/) pattern.  It's recommended that you read up on the pattern at the official site if you're not already familiar with it to get some helpful context.

## Quickstart
You'll need an environment with the following tools:
<dl>
<dt>make</dt>
<dd>🧙 <a href="https://www.gnu.org/software/make/" target="_blank">Make</a> is a tool as old as time, install it with your favorite package manager if you don't already have it.</dd>
<dt>docker</dt>
<dd>🐳 <a href="https://www.docker.com/" target="_blank">Docker</a> is a popular container tool suite.  For 3 Musketeers we need the docker CLI and the ability to run container images locally.</dd>
<dt>docker-compose</dt>
<dd>🎛️ <a href="https://docs.docker.com/compose/" target="_blank">Docker Compose</a> is a tool for managing multiple services via Docker (you may already have this if you've installed Docker).</dd>
</dl>

That's it!  The whole point of the 3 Musketeers pattern is that with these 3 basic tools we can run just about anything without having to install it directly on the host OS.

### check
Next run the [check.sh](check.sh) (or [check.bat](check.bat)) script to see if you're setup is ready.  This script will fetch several common tool images and run some commands for each.  In doing so, the script validates the following:
1. `make`, `docker`, and `docker-compose` are installed and in your PATH
2. Public images from hub.docker.com can be pulled down
3. Those images can be ran locally, including the tools they provide
4. Read/Write access to the local filesystem is working

If you encounter any issues, check the output for error messages.

**`TIP`** You can run individual checks using the Makefile targets (e.g. `make alpine`).  Run `make` by itself for help.

Once you've got a working setup, you can start using the examples in this project!

## Examples
In the [examples](examples) dir, you'll find an organized, curated set of example configurations to jump start your project or migration of an existing project to 3 Musketeers.

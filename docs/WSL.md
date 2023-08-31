# Windows Subsystem (for) Linux
This document contains setup tips for making WSL work in environments with additional constraints.  See sections below for situations and potential solutions.

## VPN
Some VPN clients (👀 at you GlobalProtect) don't/won't/can't configure WSL's virtual network adapter to use the host VPN correctly.  This can result in complete loss of connectivity from WSL once the VPN is started[^1].  Thankfully there is an excellent fix that can be setup as a service, so it Just Works™ even after reboots.

### wsl-vpnkit
The following steps summarize setup of [wsl-vpnkit](https://github.com/sakai135/wsl-vpnkit).  They are written for the Ubuntu WSL distribution and assume you are running commands from your home directory.

#### standalone setup/test

1. Reboot and _don't_ connect to the VPN at all (needed for initial connectivity to setup `wsl-vpnkit`)
2. Install needed tooling
    ```shell
    sudo apt-get install iproute2 iptables iputils-ping dnsutils wget
    ```
   > ⚠️  If you have issues resolving hostnames, replace the IP address after `nameserver` in `/etc/resolv.conf` with `8.8.8.8` or other DNS server (this change is temporary and will be reverted automatically).  It's possible that this change needs to be made persistent for DNS to work even after setup of `wsl-vpnkit`.  If pinging IPs works but not hostnames, see the Microsoft article [WSL has no network connectivity once connected to a VPN](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting#wsl-has-no-network-connectivity-once-connected-to-a-vpn) for steps to permanently modify the DNS resolver settings for WSL.
3. Download and unpack `wsl-vpnkit` (update `VERSION` as-needed)
    ```shell
    VERSION=v0.4.1
    wget https://github.com/sakai135/wsl-vpnkit/releases/download/$VERSION/wsl-vpnkit.tar.gz
    tar --strip-components=1 -xf wsl-vpnkit.tar.gz \
        app/wsl-vpnkit \
        app/wsl-gvproxy.exe \
        app/wsl-vm \
        app/wsl-vpnkit.service
    rm wsl-vpnkit.tar.gz
    ```
4. Run `wsl-vpnkit` in standalone mode to verify that it works
    ```shell
    sudo VMEXEC_PATH=$(pwd)/wsl-vm GVPROXY_PATH=$(pwd)/wsl-gvproxy.exe ./wsl-vpnkit
    ```

Now open another Ubuntu terminal and test connectivity.  You should be able to `ping www.google.com`, access any VPN-based hosts, etc.

Next let's set it up to run as a persistent service that starts automatically.

#### system service
1. Edit the `wsl-vpnkit.service` file making the following changes
   1. comment the line after _for wsl-vpnkit setup as a distro_
   2. uncomment the two lines after _for wsl-vpnkit setup as a standalone script_
   3. change `/full/path/to` to the full path to your `wsl-vpnkit` installation (e.g. `/home/youruser`)
   4. save and exit editor
2. Copy the edited version to the system services dir
    ```shell
    sudo cp ./wsl-vpnkit.service /etc/systemd/system/
    ```
3. Stop the running standalone instance we started earlier (`ctrl-c` in the shell it's running in)
4. Enable and start the background service
    ```shell
    sudo systemctl enable wsl-vpnkit
    sudo systemctl start wsl-vpnkit
    ```

Verify connectivity as before.  Note that it can take several seconds or more for the service to work.

[^1]: And in the case of GlobalProtect, even disconnecting doesn't resolve the loss of connectivity.

## Proxy
If you require a proxy configuration to reach certain hosts, this section is for you.

### proxy autoconfiguration script (.pac)
For proxy configurations that point to a PAC file URL, set the following environment variable (put in your `~/.bashrc` or equivalent to make the configuration persistent)

```shell
export AUTO_PROXY=http://some.proxy.host/proxy.pac
```

### proxy server
For proxy server setup, use the following environment variables

```shell
export HTTP_PROXY=http://some.proxy.host
export HTTPS_PROXY=https://some.proxy.host
```

### no proxy hosts
If you need to prevent use of the proxy to reach some hosts...

```shell
export NO_PROXY=somehost.com
```
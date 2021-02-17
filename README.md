# Hashing Module

## Setting Linux Container

### Requirements

1. In order to use Linux containers you will need to have `lxd` installed and initialized: `lxd init`. You may use the default configuration or a custom profile.

2. Install `devlxd` custom library for python following the guide at  [cristi-bourceanu/pylxd-dev](https://github.com/cristi-bourceanu/pylxd-dev)

### Setup

If you wish to test and develop the module within an isolate container, you may setup an LXC container using the script provided. You might need to edit `setup.sh` and use `sudo` for `lxc` command if your user is not privileged to call this command.

```shell
sh setup.sh
```

This will create a privileged container called *sha2fpga* with ssh enabled. It installs icarus, verilator, cocotb and cocotbext-axis. The src directory will be bound mounted to `/home/ubuntu` in the container.
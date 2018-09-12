#!/usr/bin/env bash
set -eux

# use config file to create config or pull in pre-existing one
source board_config.sh

yes 0|tockloader uninstall --jlink ${TOCKLOADER_ARGS} || true

./run_example.sh ipcclient --dont-clear-apps
./run_example.sh ipcserver --dont-clear-apps

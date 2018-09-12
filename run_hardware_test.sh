#!/usr/bin/env bash

# Tests only run on a nRF52-DK board

set -eux

# use config file to create config or pull in pre-existing one
source board_config.sh

yes 0|tockloader uninstall --jlink ${TOCKLOADER_ARGS} || true

./run_example.sh hardware_test_server --dont-clear-apps
./run_example.sh hardware_test --dont-clear-apps

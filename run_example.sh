#!/usr/bin/env bash
set -eux

cargo build --release --target=thumbv7em-none-eabi --example "$1"

elf_file_name="target/tab/$1/cortex-m4.elf"
tab_file_name="target/tab/$1.tab"

mkdir -p "target/tab/$1"
cp "target/thumbv7em-none-eabi/release/examples/$1" "$elf_file_name"

elf2tab -n "$1" -o "$tab_file_name" "$elf_file_name" --stack 2048 --app-heap 1024 --kernel-heap 1024

# use config file to create config or pull in pre-existing one
source board_config.sh

if [ "$#" -ge "2" ]
then
    if [ "$2" = "--dont-clear-apps" ]
    then
        echo "do not delete apps from board."
    else
        tockloader uninstall --jlink ${TOCKLOADER_ARGS} || true
    fi
else
    tockloader uninstall --jlink ${TOCKLOADER_ARGS} || true
fi
tockloader install --jlink ${TOCKLOADER_ARGS} "$tab_file_name"
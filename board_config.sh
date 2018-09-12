#!/usr/bin/env bash
CFG_FILE=$HOME/.libtock.cfg

if [[ -f $CFG_FILE ]]; then
    source $CFG_FILE
else
    source board_defs.sh
    echo "Specify board (nrf52dk, launchxl-cc26x2r1)"
    read board_input

    set +x
    for t in ${boards[@]}; do

        IFS=':' read -r id string <<< "$t"
        if  [[ $board_input == $id ]]; then
          IFS='+' read -r -a array <<< "$string"
          # this section is too chatty for -x
          
          BOARD=$id
          ARCH=${array[0]}
          JTAG_DEVICE=${array[1]}
          APP_ADDRESS=${array[2]}

          TOCKLOADER_ARGS="--board ${BOARD}"
          if [ "$ARCH" ]; then
          TOCKLOADER_ARGS+=" --arch ${ARCH}"
          fi
          if [ "$JTAG_DEVICE" ]; then
          TOCKLOADER_ARGS+=" --jtag-device ${JTAG_DEVICE}"
          fi
          if [ "$APP_ADDRESS" ]; then
          TOCKLOADER_ARGS+=" --app-address ${APP_ADDRESS}"
          fi
          set -x

          # save to config file
          echo "BOARD=$BOARD" > $CFG_FILE
          echo "ARCH=$ARCH" >> $CFG_FILE
          echo "JTAG_DEVICE=$JTAG_DEVICE" >> $CFG_FILE
          echo "APP_ADDRESS=$APP_ADDRESS" >> $CFG_FILE
          echo "TOCKLOADER_ARGS=\"${TOCKLOADER_ARGS}\"" >> $CFG_FILE
          return
        fi
    done

  if [ -z "$BOARD" ]; then
    echo "Did not find board $board_input"
    exit 0
  fi
fi


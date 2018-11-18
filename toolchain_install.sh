#!/usr/bin/env bash

chmod +x mbed-ci/toolchain_install.sh
. mbed-ci/toolchain_install.sh && linux_default_download

$HOME/bin/arm-none-eabi-gcc --version

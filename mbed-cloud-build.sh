#!/bin/bash -x

cloudbuild() {
  git clone https://github.com/iconservo/mbed-cloud-client-example $1

  cd $1
  git checkout $2
  mbed deploy

  [ -z "$CI" ] && mbed config GCC_ARM_PATH $HOME/bin

  # patch for faster builds
  cd mbed-os
  for patch in ../../patches_/*.patch ; do
    echo $patch
    patch -s -p 1 < $patch
  done
  cd ..

  # copy credentials
  cp ../mbed_cloud_dev_credentials.c .
  echo making dir BUILD
  mkdir -p BUILD

  # compile possible configs
  mbed compile -t GCC_ARM -m K64F | tee BUILD/build_log_K64F.log
  mbed compile -t GCC_ARM -m K64F --app-config configs/wifi_esp8266_v4.json --build BUILD/K64F-WIFI | tee BUILD/build_log_K64F-WIFI.log
  mbed compile -t GCC_ARM -m NUCLEO_F411RE --app-config configs/wifi_f411re_v4.json | tee BUILD/build_log_NUCLEO_F411RE.log
  mbed compile -t GCC_ARM -m UBLOX_EVK_ODIN_W2 | tee build_log_UBLOX_EVK_ODIN_W2.log | tee BUILD/build_log_UBLOX_EVK_ODIN_W2.log

  find BUILD -type f -not \( -name "${1}*" -or -name mbed_config.h -or -name "build_log*.log" \) -delete
  find BUILD -type d -empty -delete
  cd ..
}

fullbuild() {
  export MBED_BUILD_TIMESTAMP=42
  cloudbuild cloud-1.5 1.5.0
  cloudbuild cloud-2.0 2.0.1.1
}

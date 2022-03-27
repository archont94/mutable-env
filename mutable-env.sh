#!/bin/bash
set -e
trap 'echo "\"${BASH_COMMAND}\" command filed with exit code $?."' EXIT

function find_device()
{
  dev="$1"

  dev_usb=$(lsusb | grep "$dev" | head -1 )
  if [ -z "${dev_usb}" ]; then
    set -x
    echo "ERROR: No ${dev} found!"
    exit 1
  fi
  dev_bus=$(echo "${dev_usb}" | sed "s/Bus \([0-9]*\) Device \([0-9]*\):.*/\/dev\/bus\/usb\/\1\/\2/" )
  echo "--device ${dev_bus}"
}

docker_args=(run)
docker_args+=( $(find_device "ST-LINK") )
docker_args+=(-v $(pwd):/workdir)
docker_args+=(mutable-env:latest)
docker_args+=(bash -c "cd /workdir && $*")
docker "${docker_args[@]}"

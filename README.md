# Docker environment for Mutable Instruments modules hacking

This Dockerfile and this shellscript create a Docker container configured with all the right tools for compiling and installing the firmware of Mutable Instrument's modules.

## Kudos and inspiration

* pichenettes's [mutable-dev-environment](https://github.com/pichenettes/mutable-dev-environment)

## Requirements

* [Docker](https://www.docker.com/)

## Usage

First, pull Docker image:
```bash
docker pull archont94/mutable-env:latest
```

Download mutable-env.sh and save it inside `/usr/local/bin`:
```bash
wget -O /usr/local/bin/mutable-env.sh https://raw.githubusercontent.com/archont94/mutable-env/master/mutable-env.sh && chmod +x /usr/local/bin/mutable-env.sh
```

Change directory to [eurorack](https://github.com/pichenettes/eurorack) (to init it properly: `git clone https://github.com/pichenettes/eurorack.git && cd eurorack && git submodule init && git submodule update`)

Call mutable-env with desired arguments, i.e. `mutable-env make -f yarns/makefile upload`

## Different programmers/serial devices

In order to use different programmer than ST-LINK, modify your script in `/usr/local/bin/mutable-env.sh`, i.e. you can add replace ST-LINK line with i.e. `docker_args+=( $(find_device "FT232") )`.

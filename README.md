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
sudo wget -O /usr/local/bin/mutable-env https://raw.githubusercontent.com/archont94/mutable-env/master/mutable-env.sh && sudo chmod +x /usr/local/bin/mutable-env
```

Change directory to [eurorack](https://github.com/pichenettes/eurorack) (to init it properly: `git clone https://github.com/pichenettes/eurorack.git && cd eurorack && git submodule init && git submodule update`)

Call mutable-env with desired arguments, i.e. `mutable-env make -f yarns/makefile upload`

Example output:
```bash
archont@docker:~/dockers/mutable-env/eurorack$ mutable-env make -f yarns/makefile upload
openocd -s /opt/local/share/openocd/scripts/ -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c "init" -c "halt" -c "sleep 200" \
                                -f stmlib/programming/jtag/erase_f10x.cfg \
                                -c "flash write_image erase build/yarns/yarns_bootloader_combo.bin 0x08000000" \
                                -c "verify_image build/yarns/yarns_bootloader_combo.bin 0x08000000" \
                                -c "sleep 200" -c "reset run" -c "shutdown"
Open On-Chip Debugger 0.11.0
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
WARNING: interface/stlink-v2.cfg is deprecated, please switch to interface/stlink.cfg
Info : auto-selecting first available session transport "hla_swd". To override use 'transport select <transport>'.
Info : The selected transport took over low-level target control. The results might differ compared to plain JTAG/SWD
Info : clock speed 1000 kHz
Info : STLINK V2J35M26 (API v2) VID:PID 0483:3752
Info : Target voltage: 3.263684
Info : stm32f1x.cpu: hardware has 6 breakpoints, 4 watchpoints
Info : starting gdb server for stm32f1x.cpu on 3333
Info : Listening on port 3333 for gdb connections
target halted due to debug-request, current mode: Handler External Interrupt(25)
xPSR: 0x01000029 pc: 0x08009896 msp: 0x2000046c
Info : device id = 0x20036410
Info : flash size = 128kbytes
target halted due to debug-request, current mode: Handler HardFault
xPSR: 0x01000003 pc: 0xfffffffe msp: 0xffffffdc
auto erase enabled
wrote 65536 bytes from file build/yarns/yarns_bootloader_combo.bin in 3.626529s (17.648 KiB/s)

verified 64676 bytes in 0.948389s (66.597 KiB/s)

shutdown command invoked
"docker "${docker_args[@]}"" command filed with exit code 0.
archont@docker:~/dockers/mutable-env/eurorack$
```

If you want to just build binaries you can set `SKIP_PROGRAMMING` variable, i.e. `SKIP_PROGRAMMING=true mutable-env make -f yarns/makefile bin`

Example output:
```bash
archont@docker:~/dockers/mutable-env/eurorack$ SKIP_PROGRAMMING=true ../mutable-env.sh make -f yarns/makefile bin
cat build/yarns/just_intonation_processor.d build/yarns/layout_configurator.d build/yarns/midi_handler.d build/yarns/multi.d build/yarns/part.d build/yarns/resources.d build/yarns/settings.d build/yarns/storage_manager.d build/yarns/ui.d build/yarns/voice.d build/yarns/yarns.d build/yarns/channel_leds.d build/yarns/dac.d build/yarns/display.d build/yarns/encoder.d build/yarns/gate_output.d build/yarns/midi_io.d build/yarns/switches.d build/yarns/system.d build/yarns/random.d build/yarns/bootloader_utils.d build/yarns/system_clock.d build/yarns/core_cm3.d build/yarns/system_stm32f10x.d build/yarns/misc.d build/yarns/stm32f10x_adc.d build/yarns/stm32f10x_bkp.d build/yarns/stm32f10x_can.d build/yarns/stm32f10x_crc.d build/yarns/stm32f10x_dac.d build/yarns/stm32f10x_dbgmcu.d build/yarns/stm32f10x_dma.d build/yarns/stm32f10x_exti.d build/yarns/stm32f10x_flash.d build/yarns/stm32f10x_fsmc.d build/yarns/stm32f10x_gpio.d build/yarns/stm32f10x_i2c.d build/yarns/stm32f10x_iwdg.d build/yarns/stm32f10x_pwr.d build/yarns/stm32f10x_rcc.d build/yarns/stm32f10x_rtc.d build/yarns/stm32f10x_sdio.d build/yarns/stm32f10x_spi.d build/yarns/stm32f10x_tim.d build/yarns/stm32f10x_usart.d build/yarns/stm32f10x_wwdg.d build/yarns/startup_stm32f10x_md.d > build/yarns/depends.mk
/usr/local/arm-4.8.3/bin/arm-none-eabi-objcopy -O binary build/yarns/yarns.elf build/yarns/yarns.bin
"docker "${docker_args[@]}"" command filed with exit code 0.
archont@docker:~/dockers/mutable-env/eurorack$ ls -lash build/yarns/yarns.bin
60K -rwxr-xr-x 1 root root 60K Feb 22 12:38 build/yarns/yarns.bin
```


## Different programmers/serial devices

In order to use different programmer than ST-LINK, modify your script in `/usr/local/bin/mutable-env.sh`, i.e. you can add replace ST-LINK line with i.e. `docker_args+=( $(find_device "FT232") )`.

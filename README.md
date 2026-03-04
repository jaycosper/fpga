# FPGA Repository
Source the shell script to add yosys to path

# CTags
- install universal-ctags through apt
- install extension Ctags Companion
- Add command to User settings.json file for SystemVerilog parsing
    - "ctags-companion.command": "ctags -R --fields=+nKz --langmap=SystemVerilog:+.v",
- Run CTags task
    - From toolbar menu
    - Terminal → Run Task…
    - In drop-down, click show all tasks…
    - Click CTags Companion: rebuild ctags
    - A tags file will be created in the root directory
- This file _tags_ should be ignored when performing searches

To directly create tag file from command prompt:
```
$ ctags -R --fields=+nKz --langmap=SystemVerilog:+.v
```

# Todo
- Create reusable/common directory
- Create modules
    - Systemverilog
        - Systemverilog register map (with simple accessors for other modules)
        - Interface example
    - Devices
        - generic SPI peripheral (target)
        - generic I2C target
        - generic UART target
- DSP
    - FIR example
    - Lamda (IIR) example
    - Sine Loopkup table
    - Frequency sweep (0 to Fs/2)
    - Audio examples
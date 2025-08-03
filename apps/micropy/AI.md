# Gemini Project Configuration

This file helps Gemini understand the conventions and setup of this project.

## Project Overview

This project is for managing and deploying MicroPython applications.

## Coding Conventions

- External Python code taken as is from the vendor
- Bash:
  - always use `test`, never use `[]` or `[[ ]]`
  - avoid complex Bash magic
  - but use common tools as needed (`sed`, `awk`)
- Make:
  - avoid long scripts
  - create helper "command vars" (see `$(ssh)` and `$(pimake)` in [Makefile](Makefile))
  - always use `.PHONY: ⚙️` and `command: ⚙️`, never use `.PHONY: command` to make commands phony

> [!NOTE]
> Make sure all code is super readable! \
> But do not become too chatty on comments. \
> Regard the current [Makefile](Makefile) as the standard.

- Spellcheck:
  - only check words
  - allow articles to be omitted
  - allow shortening words like "mod" for "to modify"
  - allow terminal verbs like "cp" for "to copy"
  - overall try to keep text as is
  - but correct obvious mistakes like "mamager" (typo for "manager")

## App: [EP-0249](EP-0249/)
- 52Pi/GeekPi 4xUSB 2-Channel 5V Power supply module/unit (PSU)
- comes with a programmable Pi Pico to monitor the PSU and control the OLED
- See [https://wiki.52pi.com/index.php?title=EP-0249](https://wiki.52pi.com/index.php?title=EP-0249)

## Testing

Not defined so far

## Remote Setup
```
[DevHost] <--ssh--> [BridgeHost] <--usb--> [MicroController]
```
- **Developer Machine**: Desktop Linux or MacOS
  - assume the developer can install anything that is missing for local development
  - tools: `make`, VSCode, `python` (in `.venv`), helper scripts in the outer project
- **Bridge Machine**:
  - RPi4 running std. Raspberry Pi OS (non-GUI)
- **Micro Controller**: Raspberry Pi Pico
  - soldered to the PSU
  - GPIO-connected to an small OLED (128x32px)
  - USB-connected to the RPi4

## Files
```
.                         # sub-project root (no need to look upwards)
├── EP-0249               # files to be used on the bridge/pico
│   ├── ina3221.py
│   ├── main.py
│   ├── Makefile          # separate Makefile to be used on the bridge (RPi4)
│   └── ssd1306.py
├── GEMINI.md             # your instructions
├── Makefile              # automate and control everything from the DevHost
└── requirements.txt      # defines DevHost tools
```

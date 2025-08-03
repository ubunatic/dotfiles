# EP-2049 Pico Setup

OLED driver and setup code for the 52Pi/GeekPi 4xUSB 2-Channel 5V Power Supply Unit (PSU)

## Installation

> [!IMPORTANT]
> Make sure your USB-C cable is a data cable and not just a cheap charging cable.

1. Unplug the DC-input of the PSU<sup>[1](#bootsel-notes)</sup>
2. Wire USB-C cable to USB port on a bridge host or dev machine used to program the Pico
3. Turn on the bridge host that should be connected to the Pico
4. Hold the BOOTSEL button
5. Wire the USB-C cable into the Pico

**If you did it correctly:**
- Red LED on the back of the UPS will be ON
- Pico will NOT blink
- Pico will appear as "Raspberry Pi RP2 Boot" USB device on the bridge host

> [!Note]
> You can turn on the PSU if needed by plugging in the DC-input. \
> The Pico will stay in boot mode now.

**If you did it wrong:**
- Red LED on the back of the UPS will also be ON
- Pico will blink frantically
- Pico will NOT appear as USB device

Also see [https://wiki.52pi.com/index.php?title=EP-0249](https://wiki.52pi.com/index.php?title=EP-0249)

## `BOOTSEL` Notes
To enter boot mode the PSU must be turned OFF.

I did not yet find a way to do the boot steps while the PSU power is on.
This means your bridge host must be powered separately when programming the Pico.
Which seems a bit of a design flaw, given the device is a PSU to power a few RPi machines.

There are some guides how to add another `BOOTSEL` button to the Pico (not sure this helps).
There are also firmwares which make the button work while the Pico is powered. But I did not try any of this.

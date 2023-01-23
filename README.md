# rpiplc_pas
This is a Pascal wrapper for [rpiplc-lib](https://github.com/Industrial-Shields/rpiplc-lib).  The rpiplc library must be installed for the wrapper to work (see instructions on linked page). This allows one to write Pascal based software that can interact with the digital and analog I/O of the [Raspberry Pi based PLC](https://www.industrialshields.com/programmable-logic-controllers-based-on-arduino-raspberry-pi-and-esp32-20220909-lp#raspberry).

## Example
The _rpipl\_pas_ command line application in the example folder allows one to read from or write to the digital and analog pins.  
Usage:
```
$ ./rpiplc_pas <operation> <channel> <pin> [<value>]
<operation> is:
  ai - read analog input pin
  ao - write analog output pin
  di - read digital input pin
  do - write digital output pin
  ro - write relay output pin

<channel> is 0, 1, 2 (channels depend on the specific shield option)

-<pin> is the pin number (pins depend on the specific shield option)

<value> (Output only) value to write to pin (0/1 for digital and relay pins, 0-4095 for analog pins)
```

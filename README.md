Skylanders Trap Team GamePad (Bluetooth low energy)
===========================

The tablet version of Skylanders Trap Team comes with both an NFC reading portal, as well as a Bluetooth low energy GamePad.
This application communicates with the Skylanders GamePad and uses a Virtual Joystick to simulate the controller.

## Provenance

This is basically a rewrite of the controller communication part of [Xbox One Controller Enabler](https://github.com/guilhermearaujo/xboxonecontrollerenabler/releases).  I replaced its use of USB and Xbox's controller protocol with BLE and the Skylanders GamePad protocol.  As such, some class, method, variable names, and such may still make references to Xbox, or USB.  That cleanup is only of moderate utility, yet time consuming and error prone.

This application is built on top of Alexandr Serkov's great VHID and WirtualJoy frameworks, from his [WJoy](https://code.google.com/p/wjoy/ "WJoy Project on Google Code") project. These are responsible for the Virtual HID that the system will see as a controller.

### Cleanup
 * New icon
 * Update controller image in UI
 * Remove polling code
 * Rename things from Xbox

## GamePad protocol
Service UUID 0x1531, one characteristic that has read and notify, returns 20 byte more than 1/second (haven't determined actually rate).

* value[8]
 * D-pad Up: 0x01
 * D-pad Down: 0x02
 * D-pad Left: 0x04
 * D-pad Right: 0x08
 * A Button: 0x10
 * B Button: 0x20
 * X Button: 0x40
 * Y Button: 0x80
* value[9]
 * L1: 0x10
 * R1: 0x20
* value[10] L2 when 0xFF
* value[11] R2 when 0xFF
* value[12] Right stick x-axis as a signed byte
* value[13] Right stick y-axis as a signed byte
* value[14] Left stick x-axis as a signed byte
* value[15] Left stick y-axis as a signed byte


### Thanks to:
* Guilherme Araújo for [Xbox One Controller Enabler](https://github.com/guilhermearaujo/xboxonecontrollerenabler)
* [Cyko28](http://www.reddit.com/user/Cyko28) for the [reddit post](http://www.reddit.com/r/apple/comments/2oz7le/heres_a_free_reliable_xbox_one_controller_enabler/) that pointed to the Xbox enabler project
* Kyle Lemons for figuring out how to power the controller (check his [xbox](https://github.com/kylelemons/xbox) project).
* Brandon Jones for nicely laying out the [button mapping](http://blog.tojicode.com/2014/02/xbox-one-controller-in-chrome-on-osx.html) of the controller.
* Lucas Assis for his work on [Windows drivers](https://xboxonegamepad.codeplex.com/) for the controller.
* Alexandr Serkov for providing nice Virtual HID drivers ([WJoy](https://code.google.com/p/wjoy/)).

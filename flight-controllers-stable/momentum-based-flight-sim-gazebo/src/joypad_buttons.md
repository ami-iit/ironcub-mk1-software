## Flying with joypad

The joypad used is a `Steelseries Stratus XL (PN69050)`. [How to run the joypad module](https://github.com/robotology/walking-controllers#how-to-run-the-joypad-module)

![MicrosoftTeams-image (1)](https://github.com/ami-iit/ironcub_mk1_software/assets/12396934/6f12ff30-2612-4271-a698-c3453ec38e25)
![MicrosoftTeams-image](https://github.com/ami-iit/ironcub_mk1_software/assets/12396934/f27d2835-926f-4366-9e03-49356c68d176)

The module opens two ports: `/joypadDevice/xbox/buttons:o` and `/joypadDevice/xbox/axis:o`

### Buttons Port Mapping

The port streams a vector with zeros and ones. One is when the corresponding button is pressed.

- element 1 -> A
- element 2 -> B
- element 3 -> X
- element 4 -> Y
- element 5 -> L1
- element 6 -> R1
- element 10 -> right small arrow
- element 11 -> press left pad
- element 12 -> press right pad
- element 13 -> up arrow
- element 14 -> down arrow
- element 15 -> left arrow
- element 16 -> right arrow
- element 19 -> left small arrow
- element 20 -> o (center) button
- element 21 -> wifi button
- element 22 -> battery button

### Axis Port Mapping

The port streams a vector with zeros and +/- ones.

- axis 1 -> left pad, left-right motion (from -1 to 1)
- axis 2 -> left pad, up-down motion (from -1 to 1)
- axis 3 -> right pad, left-right motion (from -1 to 1)
- axis 4 -> L2 (from -1 to 1)
- axis 5 -> R2 (from -1 to 1)
- axis 6 -> right pad, up-down motion (from -1 to 1) 

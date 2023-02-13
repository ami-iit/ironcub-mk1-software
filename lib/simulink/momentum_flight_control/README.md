# Momentum-Based Flight Controller Library

This library collects all blocks related to the momentum-based iRonCub flight control.

## List of library blocks

- `Flight Controller RAL-HUMANOIDS V3.0`: momentum-based + inverse dynamics control for flight;

- `Flight State Machine`: provides references to the controller;

- `Dynamics and Kinematics`: computes dynamics and kinematics quantities to be used by the controller;

- `Get System State`: get the full flying robot state, composed of base pose, joint positions, jet thrust intensities and contact forces (if any), and their time derivatives.

- `Compute Fuel Consumption`: estimates the fuel consumption during flight; 

- `JoyStick-flightGUI Commands`: map the Joypad/flightControlGUI inputs to references variations.

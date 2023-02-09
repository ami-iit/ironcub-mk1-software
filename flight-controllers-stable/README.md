## Flight controllers

Flight controllers for simulations with iRonCub-Mk1 and iRonCub-Mk1_1. 

**All controllers are developed and tested on Ubuntu 20.04 LTS**.

### Usage

TO BE UPDATED 

### Contents

- [controlAndDataGui](controlAndDataGui): a couple of GUIs for the robot control and data visualization in simulation.

- [matlab-functions-lib](matlab-functions-lib): MATLAB functions and scripts shared by all controllers.

- [momentum-based-flight-sim-gazebo](momentum-based-flight-sim-gazebo): this Simulink model implements the flight controller presented in the [IEEE-RAL 2018 paper](https://ieeexplore.ieee.org/document/7997895) and in the [IEEE-HUMANOIDS 2018 paper](https://github.com/dic-iit/element_ironbot-control/tree/master/papers/Humanoids2018). It works in simulation in combination with Gazebo. 

- [momentum-based-flight-sim-no-gazebo](momentum-based-flight-sim-no-gazebo): this Simulink model implements the flight controller presented in the [IEEE-RAL 2018 paper](https://ieeexplore.ieee.org/document/7997895) and in the [IEEE-HUMANOIDS 2018 paper](https://github.com/dic-iit/element_ironbot-control/tree/master/papers/Humanoids2018). It is self-contained in MATLAB, and does not require Gazebo to run. 

# Flight Controllers Stable

Simulink flight controllers for simulations with iRonCub-Mk1 and iRonCub-Mk1_1. 

**All controllers are developed and tested on Ubuntu 20.04 LTS**.

## Content

- [controlAndDataGui](controlAndDataGui): a couple of GUIs for the robot control and data visualization in simulation.

- [matlab-functions-lib](matlab-functions-lib): MATLAB functions and scripts shared by all controllers.

- [momentum-based-flight-sim-gazebo](momentum-based-flight-sim-gazebo): this Simulink model implements the flight controller presented in [[1](https://ieeexplore.ieee.org/document/7997895)], [[2](https://ieeexplore.ieee.org/document/8624985)]. It works in simulation in combination with Gazebo. 

- [momentum-based-flight-sim-no-gazebo](momentum-based-flight-sim-no-gazebo): this Simulink model implements the flight controller presented in [[1](https://ieeexplore.ieee.org/document/7997895)], [[2](https://ieeexplore.ieee.org/document/8624985)]. It is self-contained in MATLAB, and does not require Gazebo to run. 

## Usage

### Gazebo Simulations

It is assumed that [all dependencies](../README.md#installation) have been correctly installed. **The procedure is tested on Ubuntu 20.04 LTS**.

**Before starting:** set the `YARP_ROBOT_NAME` env. variable in your `.bashrc` file to be the iRonCub robot name, e.g.:

```
export YARP_ROBOT_NAME=iRonCub-Mk1_1_Gazebo 
```
or
```
export YARP_ROBOT_NAME=iRonCub-Mk1_Gazebo
```

1) open a terminal and run:

  ```
  yarpserver
  ```
  or 
  ```
  yarpserver --write
  ```
  if your IP changed.

2) open a terminal and run:

  ```
  gazebo -slibgazebo_yarp_clock.so.
  ```
  If you have correctly configured the [iRonCub world](../models/worlds), you may run also:  
  ```
  gazebo -slibgazebo_yarp_clock.so iRonCub_Mk1_1_world 
  ```
  (world for `iRonCub-Mk1_1`).

3) **if not using the Gazebo world file**: go in the folder [home-poses](../models/home-poses), then open a terminal and run:
  ```
  yarpmotorgui --from homePoseiRonCub_Gazebo.ini
  ```
  It should open the GUI for joints control of iRonCub. Then in the top left menu, select `Global Joints Commands/Custom Positions/Move All Parts to <MY HOME POSITION>` (e.g. `flyPosition_Gazebo`).

4) open a terminal and run:
  ```
  yarprobotinterface --config launch-wholebodydynamics-iRonCub.xml
  ```
  
5) **should not be necessary anymore:** open another terminal and run (only once, unless you restart wholebodydynamics at the point 4): 
  ```
  yarp rpc /wholeBodyDynamics/rpc` and then `resetOffset all`.
  ```

6) open MATLAB. Go to the `flight-controllers-stable` folder, select the iRonCub controller you would like to use and open the associated Simulink `.mdl` file. Then press play and run the simulation.

   6a) The model can be interfaced with a joypad or with a MATLAB GUI. To Activate/deactivate the GUI check the [init file](momentum-based-flight-sim-gazebo/initMomentumBasedFlight.m#L52). In the init file there are also other useful options to set your simulation.

   6b) If you are using the joypad you also need to run in a terminal the command (after physically connecting the joypad to your pc):
   ```
   yarpdev --device JoypadControlServer --use_separate_ports 1 --period 10 --name /joypadDevice/xbox --subdevice SDLJoypad --sticks 0
   ```
   It assumes that you have installed the joypad dependencies, more info [here](https://github.com/robotology/walking-controllers#how-to-run-the-joypad-module).

   6c) To perform gain tuning and optimize the performances of your controller, check e.g. the parameters in [this file](momentum-based-flight-sim-gazebo/app/robots/iRonCub-Mk1_1_Gazebo/gainsAndParameters.m).

### Matlab Simulations

Provided that [all dependencies](../README.md#installation) have been successfully installed, just open the file []() and run the controller. **WARNING**: bacause of its dependency to [matlab-whole-body-simulator](https://github.com/ami-iit/matlab-whole-body-simulator) library, the required Matlab version depends on the supported version in `mwbs` (currently, R2022b).

## Cite this work

```
@ARTICLE{7997895,
  author={Pucci, Daniele and Traversaro, Silvio and Nori, Francesco},
  journal={IEEE Robotics and Automation Letters}, 
  title={Momentum Control of an Underactuated Flying Humanoid Robot}, 
  year={2018},
  volume={3},
  number={1},
  pages={195-202},
  doi={10.1109/LRA.2017.2734245}}

```

```
@INPROCEEDINGS{8624985,
  author={Nava, Gabriele and Fiorio, Luca and Traversaro, Silvio and Pucci, Daniele},
  booktitle={2018 IEEE-RAS 18th International Conference on Humanoid Robots (Humanoids)}, 
  title={Position and Attitude Control of an Underactuated Flying Humanoid Robot}, 
  year={2018},
  volume={},
  number={},
  pages={1-9},
  doi={10.1109/HUMANOIDS.2018.8624985}}

```

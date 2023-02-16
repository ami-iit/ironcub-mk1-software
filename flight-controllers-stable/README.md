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

TO BE UPDATED 


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

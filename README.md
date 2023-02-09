# ironcub_software

In this repository we share public iRonCub software used throughout the project.

**WARNING! this repo is under development, and the software that contains is not supposed to work yet!**

## Installation

**Dependencies:**

- [YARP](https://github.com/robotology/yarp);
- [Gazebo](http://gazebosim.org/);
- [gazebo-yarp-plugins](https://github.com/robotology/gazebo-yarp-plugins);
- [whole-body-controllers](https://github.com/robotology/whole-body-controllers);
- [Matlab-Simulink](https://it.mathworks.com/products/matlab.html), **at least version R2021b**.
- [iDynTree high-level wrappers](https://github.com/robotology/idyntree/tree/devel/bindings/+iDynTreeWrappers/README.md);

To understand how to quiclky install all the dependencies (but Gazebo and Matlab), follow the instructions below.

**how to install on Ubuntu**

TO BE UPDATED

**how to install on Windows**

TO BE UPDATED

## Folders

### flight-controllers-stable

This repo contains Simulink controllers that can be used to run simulations of iRonCub-Mk1 and iRonCub-Mk1_1 flying in Gazebo simulator. [README](flight-controllers-stable/README.md).

### matlab-scripts

The folder contains Matlab scripts used to determine the optimal jets configuration, robot posture for take off, and similar offline optimizations. [README](matlab-scripts/README.md).

### models

Home positions and URDF models of iRonCub-Mk1 and iRonCub-Mk1_1. [README](models/README.md).

### lib

Gazebo plugins and Simulink library blocks used in the flight controllers. [README](lib/README.md).

## Maintainer

Gabriele Nava, @gabrielenava

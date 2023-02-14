# ironcub_software

In this repository we share public iRonCub software used throughout the project.

**WARNING! this repo is under active development, and the software that contains comes with no warranties!**

## Installation


### Dependencies

- `YARP`
- `Gazebo`
- `Eigen3`
- `MATLAB R2021b & Simulink`
- `BlockFactory`
- `WB-Toolbox`

The recommended way for installing this dependencies is to use the [robotology-superbuild](https://github.com/robotology/robotology-superbuild), making sure to enable the `ROBOTOLOGY_ENABLE_DYNAMICS` and `ROBOTOLOGY_USES_GAZEBO` CMake options.

**Note:** A quick way to install the dependencies is via [conda package manager](https://docs.conda.io) which provides binary packages for Linux, macOS and Windows of the software contained in the robotology-superbuild. Relying on the community-maintained [`conda-forge`](https://conda-forge.org/) channel and also the `robotology` conda channel.

Please refer to [the documentation in `robotology-superbuild`](https://github.com/robotology/robotology-superbuild/blob/7d79a44e90fbcedf137ab6c5c1d83b943d6e6839/doc/conda-forge.md) to install and configure a conda distribution. Then, once your environment is set, you can run the following command to install the required dependencies.

```sh
mamba create -n <conda-environment-name>
mamba activate  <conda-environment-name>
mamba install -c conda-forge compilers cmake pkg-config make ninja
mamba install -c conda-forge -c robotology icub-models idyntree-matlab-bindings wb-toolbox whole-body-controllers whole-body-estimators gazebo gazebo-yarp-plugins opencv
```

The installation procedure has been tested on Ubuntu 20.04 and Windows 10.

### Compilation and installation

On **Linux** or **macOS**, run:

```bash
cd ironcub_software
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="/path/to/desired/install/dir" .
make install
```

On **Windows**, run:

```cmd
cd ironcub_software
mkdir build
cd build
cmake .. -G"Visual Studio 16 2019" -DCMAKE_INSTALL_PREFIX="\path\to\desired\install\dir"
cmake --build . --config Release --target INSTALL
```

### Setup the enviroment

#### Gazebo environment

```bash
# This can be either the installation directory or the build directory
export IRONCUB_INSTALL_PREFIX=<prefix>
# Gazebo related env variables (see http://gazebosim.org/tutorials?tut=components#EnvironmentVariables )
# Note: sourcing the gazebo setup.sh must be done only if it was not included before by another setup script of another project,
#       otherwise it will overwrite the Gazebo-related enviromental variables already set
source /usr/share/gazebo/setup.sh
export GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH}:${IRONCUB_INSTALL_PREFIX}/lib
```

Change the line `source /usr/share/gazebo/setup.sh` to the appropriate line if in your system `Gazebo` is not installed
in `/usr`. For example, when Gazebo is installed with homebrew on macOs, this line shall contain `/usr/local`, e.g. for Gazebo 8, one has `source /usr/local/share/gazebo-8/setup.sh`.

#### iRonCub Simulink library

Add to your `.bashrc`

```bash
source $IRONCUB_INSTALL_PREFIX/share/ironcub/setup.sh
```

This `sh` file contains the paths that are needed to use the simulink library.

Note that the `iDynTree Visualizer` needs to be run with the `hardware opengl`. Hence, in this script also the following line is added:

```bash
export MESA_LOADER_DRIVER_OVERRIDE=crocus
```

If you are not using an Intel graphic card or in any case you use a driver different from `crocus` (check [this issue](https://github.com/robotology/robotology-superbuild/issues/953) for further solutions!), you can just unset this variable after you source the script, for example:

```bash
source $IRONCUB_INSTALL_PREFIX/share/ironcub/setup.sh
unset MESA_LOADER_DRIVER_OVERRIDE
```

## Running the repo on Windows

To run the repository on Windows it's necessary to properly setup a windows terminal where a series of commands are automatically executed.

### Create the `setup.bat` file

Create a file `setup.bat` with the following content:

```cmd
call mamba activate <conda-environment-name>
call <path-to-the-robotology-superbuild>\robotology-superbuild\build\install\share\robotology-superbuild\setup.bat


rem From the iRonCub Software documentation
call <\path\to\desired\install\dir>\share\ironcub\setup.bat

rem Unset the MESA variable (maybe useless on Windows)
set MESA_LOADER_DRIVER_OVERRIDE=
```

In this way the `batch` file is indicating to load both the setup files from the `robotology-superbuild` and the `component_ironcub`.

### Set the Windows Terminal app

Download **Windows Terminal** from the _Microsoft Store_.

Launch the Windows Terminal app, go on `settings` and `Create a new profile`, then create a new profile specifying the new name and the tab-name.

Select `Open Json file`.

In the `settings.json` file search for `"list"` inside `"profiles"`, there in the newly generated terminal (easy to find by the `"name"` variable) set the value for `"commandline"` as:

```bash
"commandline": "cmd.exe /k \"<path-to-the-setup-file>\\setup.bat\""
```

**IMPORTANT: in the `"commandline"` path be sure to use `\\` as path separator for the correct `.json` file syntax.**

Now the Windows Terminal has the `setup.bat` file acting in a similar way to the `.bashrc` file on _Linux_ OS.

**Dependencies:**

- [YARP](https://github.com/robotology/yarp);

- [gazebo-yarp-plugins](https://github.com/robotology/gazebo-yarp-plugins);
- [whole-body-controllers](https://github.com/robotology/whole-body-controllers);
- [Matlab-Simulink](https://it.mathworks.com/products/matlab.html), **at least version R2021b**.
- [Gazebo](https://classic.gazebosim.org/download) to avoid possible bugs/incompatibilites, choose at least Gazebo 11;
- [iDynTree high-level wrappers](https://github.com/robotology/idyntree/tree/devel/bindings/+iDynTreeWrappers/README.md);

To quiclky install all the dependencies (but Gazebo and Matlab-Simulink), follow the instructions below.

**how to install on Ubuntu**

TO BE UPDATED

**how to install on Windows**

TO BE UPDATED

## Folders

### flight-controllers-stable

This repo contains Simulink controllers that can be used to run simulations of `iRonCub-Mk1` and `iRonCub-Mk1_1` flying in Gazebo simulator. [README](flight-controllers-stable/README.md).

### matlab-scripts

The folder contains Matlab scripts used to determine the optimal jets configuration, robot posture for take off, and similar offline optimizations. [README](matlab-scripts/README.md).

### models

Home positions and URDF models of `iRonCub-Mk1` and `iRonCub-Mk1_1`. [README](models/README.md).

### lib

Gazebo plugins and Simulink library blocks used in the flight controllers. [README](lib/README.md).

## Maintainer

Gabriele Nava, @gabrielenava


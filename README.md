# iRonCub-Mk1 Software

**WARNING! this repo is under active development, and the software that contains comes with no warranties!**

This repo contains libraries, plugins and controllers to perform dynamics simulations of the flying humanoid robot iRonCub. iRonCub is the world first jet-powered humanoid robot and it is being developed by the [Artificial and Mechanical Intelligence](https://ami.iit.it/) group at the Italian Institute of Technology (IIT). For further information on the project, please visit the [arerial humanoid robotics page](https://ami.iit.it/aerial-humanoid-robotics).

https://user-images.githubusercontent.com/12396934/219008717-117eb146-cca6-4056-8dd1-9a06100e97d1.mp4

## Installation

### Dependencies

- [YARP](https://github.com/robotology/yarp);
- [gazebo-yarp-plugins](https://github.com/robotology/gazebo-yarp-plugins);
- [whole-body-controllers](https://github.com/robotology/whole-body-controllers);
- [Matlab & Simulink](https://it.mathworks.com/products/matlab.html);
- [Gazebo](https://classic.gazebosim.org/download);
- [iDynTree](https://github.com/robotology/idyntree);
- [BlockFactory](https://github.com/robotology/blockfactory);
- [Eigen3](https://eigen.tuxfamily.org/index.php?title=Main_Page);
- [matlab-whole-body-simulator](https://github.com/ami-iit/matlab-whole-body-simulator).

**Note:** the lowest suppported Matlab version is `R2021b`, and the lowest supported Gazebo version is `v.8`. For controllers that use Simulink library blocks from `matlab-whole-body-simulator`, the lowest supported Matlab version is `R2022b`.

The **highly recommended** way for installing all this dependencies (but Matlab and Gazebo) is to use the [robotology-superbuild](https://github.com/robotology/robotology-superbuild), making sure to enable the `ROBOTOLOGY_ENABLE_DYNAMICS` and `ROBOTOLOGY_USES_GAZEBO` CMake options. 

A quick way to install the dependencies is via [conda package manager](https://docs.conda.io) which provides binary packages for Linux, macOS and Windows of the software contained in the robotology-superbuild. Relying on the community-maintained [`conda-forge`](https://conda-forge.org/) channel and also the `robotology` conda channel.

Please refer to [the documentation in `robotology-superbuild`](https://github.com/robotology/robotology-superbuild/blob/7d79a44e90fbcedf137ab6c5c1d83b943d6e6839/doc/conda-forge.md) to install and configure a conda distribution. Then, once your environment is set, you can run the following command to install the required dependencies.

```sh
mamba env create -n <conda-environment-name> --file environment.yml
mamba activate  <conda-environment-name>
```

The installation procedure has been tested on Ubuntu 20.04 and Windows 10.

## Compilation

On **Linux** or **macOS**, run:

```bash
cd ironcub_mk1_software
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="/path/to/desired/install/dir" .
make install
```

On **Windows**, run:

```cmd
cd ironcub_mk1_software
mkdir build
cd build
cmake .. -G"Visual Studio 16 2019" -DCMAKE_INSTALL_PREFIX="\path\to\desired\install\dir"
cmake --build . --config Release --target INSTALL
```

> [!warning]
> "If you haven't configured [`git lfs`](https://git-lfs.com/), run `git lfs install` and `git lfs pull` inside the `ironcub_mk1_software` folder."


## Running the repo on Windows

To run the repository on Windows it is necessary to properly setup a Windows terminal where commands are executed. First, create a file `setup.bat` with the following content:

```cmd
call mamba activate <conda-environment-name>
call <path-to-the-robotology-superbuild>\robotology-superbuild\build\install\share\robotology-superbuild\setup.bat

rem From the iRonCub Software documentation
call <\path\to\desired\install\dir>\share\ironcub\setup-v1.bat

rem Unset the MESA variable (maybe useless on Windows)
set MESA_LOADER_DRIVER_OVERRIDE=
```

In this way the `batch` file will load both the setup script from the `robotology-superbuild` and the `ironcub_mk1_software`. Then, download **Windows Terminal** from the _Microsoft Store_.

Launch the Windows Terminal app, go on `settings` and `Create a new profile`, then create a new profile specifying the new name and the tab-name.

Select `Open Json file`.

In the `settings.json` file search for `"list"` inside `"profiles"`, there in the newly generated terminal (easy to find by the `"name"` variable) set the value for `"commandline"` as:

```bash
"commandline": "cmd.exe /k \"<path-to-the-setup-file>\\setup.bat\""
```

**IMPORTANT: in the `"commandline"` path be sure to use `\\` as path separator for the correct `.json` file syntax.**

Now the Windows Terminal has the `setup.bat` file acting in a similar way to the `.bashrc` file on _Linux_ OS.

## Running the repo on Ubuntu

Add to your `.bashrc` file the following line:

```bash
source $IRONCUB_INSTALL_PREFIX/share/ironcub/setup-v1.sh
```

This `sh` file contains the paths that are needed to use this repo. 

**For Gazebo simulations:**

To better understand which variables are set by the `setup-v1.sh` script, see also these READMEs:

- https://github.com/ami-iit/ironcub_mk1_software/tree/porting_mk1_mk1_1/models/worlds#usage
- https://github.com/ami-iit/ironcub_mk1_software/blob/porting_mk1_mk1_1/lib/gazebo/README.md#setting-up-env-variables
- https://github.com/ami-iit/ironcub_mk1_software/tree/porting_mk1_mk1_1/models#installation-and-usage

## Content

Documentation entry points for the different folders are in the [wiki](https://github.com/ami-iit/ironcub_mk1_software/wiki) of the repo.

- [flight-controllers-stable](flight-controllers-stable): Simulink controllers to run simulations of `iRonCub-Mk1` and `iRonCub-Mk1_1` flying in Gazebo simulator.

- [matlab-scripts](matlab-scripts): Matlab scripts used to determine the optimal jets configuration, robot posture for take off, and similar offline optimizations.

- [models](models): home positions and URDF models of `iRonCub-Mk1` and `iRonCub-Mk1_1`.

- [lib](lib): Gazebo plugins and Simulink library blocks to be used in the flight controllers.

## Maintainer

Gabriele Nava, [@gabrielenava](https://github.com/gabrielenava)

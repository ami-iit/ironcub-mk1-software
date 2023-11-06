# iRonCub-Mk1 Software

**WARNING! this repo is under active development, and the software that contains comes with no warranties!**

This repo contains libraries, plugins and controllers to perform dynamics simulations of the flying humanoid robot iRonCub. iRonCub is the world first jet-powered humanoid robot and it is being developed by the [Artificial and Mechanical Intelligence](https://ami.iit.it/) group at the Italian Institute of Technology (IIT). For further information on the project, please visit the [arerial humanoid robotics page](https://ami.iit.it/aerial-humanoid-robotics).

https://user-images.githubusercontent.com/12396934/219008717-117eb146-cca6-4056-8dd1-9a06100e97d1.mp4

## Dependencies

- [YARP](https://github.com/robotology/yarp);
- [gazebo-yarp-plugins](https://github.com/robotology/gazebo-yarp-plugins);
- [whole-body-controllers](https://github.com/robotology/whole-body-controllers);
- [Matlab & Simulink](https://it.mathworks.com/products/matlab.html);
- [Gazebo](https://classic.gazebosim.org/download);
- [iDynTree](https://github.com/robotology/idyntree);
- [BlockFactory](https://github.com/robotology/blockfactory);
- [Eigen3](https://eigen.tuxfamily.org/index.php?title=Main_Page);
- [matlab-whole-body-simulator](https://github.com/ami-iit/matlab-whole-body-simulator).

> [!NOTE]
> The oldest suppported Matlab version is `R2021b`, and the oldest supported Gazebo version is `v.8`. For controllers that use Simulink library blocks from `matlab-whole-body-simulator`, the lowest supported Matlab version is `R2022b`.


A possible way for installing all this dependencies, except Matlab and Gazebo, is to use the [robotology-superbuild](https://github.com/robotology/robotology-superbuild).
An alternative is the usage of a [conda package manager](https://docs.conda.io) which provides binary packages for Linux, macOS and Windows.
Please refers to the next sections for more details.

## Installation via robotology-superbuild (Linux Only)

First, you must install [matlab](https://it.mathworks.com/products/matlab.html) and [Gazebo](https://classic.gazebosim.org/download).
Then, you have to configure the other dependencies via [robotology-superbuild](https://github.com/robotology/robotology-superbuild) making sure to enable the `ROBOTOLOGY_ENABLE_DYNAMICS`, `ROBOTOLOGY_USES_GAZEBO` CMake options, and checkout to tag [`v2023.08.0`](https://github.com/robotology/robotology-superbuild/releases/tag/v2023.08.0).
After setting up the `robotology-superbuild`, proceed to set up this repository.

### Compilation

Execute the following commands in your terminal:

```bash
git clone https://github.com/ami-iit/ironcub_mk1_software.git
cd ironcub_mk1_software
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=</path/to/desired/install/dir>
make install
```

### Using the Repository

In the first use, add the following line to your `.bashrc` file:

```bash
source $IRONCUB_INSTALL_PREFIX/share/ironcub/setup-v1.sh
```

## Installation with Conda (Linux and Windows)

Start by installing [Matlab](https://it.mathworks.com/products/matlab.html).
Next, you have to install and configure a conda distribution following [the documentation in `robotology-superbuild`](https://github.com/robotology/robotology-superbuild/blob/7d79a44e90fbcedf137ab6c5c1d83b943d6e6839/doc/conda-forge.md). Then, once your environment is set, you can run the following command to install the required dependencies.

```sh
git clone https://github.com/ami-iit/ironcub_mk1_software.git
cd ironcub_mk1_software
mamba env create -n <conda-environment-name> --file environment.yml
```

### Compilation

For **Linux** or **macOS**, execute the following commands:

```bash

mamba activate <conda-environment-name>
cd ironcub_mk1_software
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=</path/to/desired/install/dir>
make install
echo "source </path/to/desired/install/dir>/share/ironcub/setup_v1.sh" > "${CONDA_PREFIX}/etc/conda/activate.d/ironcub_setup.sh"
chmod +x "${CONDA_PREFIX}/etc/conda/activate.d/ironcub_setup.sh"
```

For **Windows**, run these commands:

```cmd
mamba activate <conda-environment-name>
cd ironcub_mk1_software
mkdir build
cd build
cmake .. -G"Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX=<\path\to\desired\install\dir>
cmake --build . --config Release --target INSTALL
echo call "<path\to\desired\install\dir>\share\ironcub\setup_v1.bat" > "%CONDA_PREFIX%\etc\conda\activate.d\ironcub_setup.bat"
```

> [!warning]
> If you haven't configured [`git lfs`](https://git-lfs.com/), run `git lfs install` and `git lfs pull` inside the `ironcub_mk1_software` folder.

### Using the Repository

Open the terminal and activate the conda environment

```bash
mamba activate <conda-environment-name>
```

> [!NOTE]
> Activating the environment will automatically source `setup_v1.sh` (`setup_v1.bat` for windows).  If you want to deactivate the sourced variables, you should open a new terminal.
> To better understand which variables are set by the `setup_v1.sh` script, see also these READMEs: [worlds](models/worlds/README.md#usage), [gazebo](lib/gazebo/README.md#setting-up-env-variables), and [models](models/README.md#installation-and-usage).

## Content

Documentation entry points for the different folders are in the [wiki](https://github.com/ami-iit/ironcub_mk1_software/wiki) of the repo.

- [flight-controllers-stable](flight-controllers-stable): Simulink controllers to run simulations of `iRonCub-Mk1` and `iRonCub-Mk1_1` flying in Gazebo simulator.

- [matlab-scripts](matlab-scripts): Matlab scripts used to determine the optimal jets configuration, robot posture for take off, and similar offline optimizations.

- [models](models): home positions and URDF models of `iRonCub-Mk1` and `iRonCub-Mk1_1`.

- [lib](lib): Gazebo plugins and Simulink library blocks to be used in the flight controllers.

## Maintainer

Gabriele Nava, [@gabrielenava](https://github.com/gabrielenava)

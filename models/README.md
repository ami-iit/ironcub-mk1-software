## iRonCub models

The models have been developed starting from the [iCub 2.5 models](https://github.com/robotology/icub-models/tree/master/iCub/robots).
More in details, the same files have been copied and adapted to generate the iRonCub models.

Versions:

- iRonCub Mk1
It's the first iRonCub version. It has been generated starting from the CAD model. The conf and the meshes are independent from [icub-models](https://github.com/robotology/icub-models).

- iRonCub Mk1_1
It's the intermediate version after iRonCub Mk1 version. It has been generated starting from the CAD model. The conf and the meshes are independent from [icub-models](https://github.com/robotology/icub-models).

### How to use models in Gazebo (on Linux)
You should add these lines in your `.bashrc` (**warning**! not needed if you source the `setup.sh` file as described in this [README](../software/README.md#ironcub-simulink-library))

``` bash
export COMPONENT_IRONCUB_PREFIX=[path where this repository is stored]
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/iRonCub-Mk1/iRonCub/robots
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/iRonCub-Mk1_1/iRonCub/robots
```

### How to use models in Gazebo (on Windows)
You should add these lines in your custom `.bat` file to be called from terminal (**warning**! not needed if you call the `setup.bat` file as described in this [README](../software/README.md#create-the-setupbat-file))

``` cmd
set IRONCUB_COMPONENT_SOURCE_DIR=[path where this repository is stored]
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_COMPONENT_SOURCE_DIR%\models\
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_COMPONENT_SOURCE_DIR%\models\iRonCub-Mk1\iRonCub\robots
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_COMPONENT_SOURCE_DIR%\models\iRonCub-Mk1_1\iRonCub\robots
```
### How to use the .urdf model with WBToolbox and Simulink (on Linux)
You should add these lines in your `.bashrc` (**warning**! not needed if you source the `setup.sh` file as described in this [README](../software/README.md#ironcub-simulink-library))

``` bash
export COMPONENT_IRONCUB_PREFIX=[path where this repository is stored]
export YARP_DATA_DIRS=${YARP_DATA_DIRS}:${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/iRonCub-Mk1/iRonCub/
export YARP_DATA_DIRS=${YARP_DATA_DIRS}:${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/iRonCub-Mk1_1/iRonCub/
```

Set the `YARP_ROBOT_NAME` variable as the name of the folder where the `model.urdf` is stored.
- `export YARP_ROBOT_NAME=iRonCub-Mk1_Gazebo` for using `iRonCub Mk1` with **Gazebo**
- `export YARP_ROBOT_NAME=iRonCub-Mk1_1_Gazebo` for using `iRonCub Mk1_1` with **Gazebo**

### How to use the .urdf model with WBToolbox and Simulink (on Windows)
You should add these lines in your custom `.bat` file to be called from terminal (**warning**! not needed if you call the `setup.bat` file as described in this [README](../software/README.md#create-the-setupbat-file))

``` cmd
set IRONCUB_SOFTWARE_SOURCE_DIR=[path where this repository is stored]
set YARP_DATA_DIRS=%YARP_DATA_DIRS%;%IRONCUB_COMPONENT_SOURCE_DIR%\models\iRonCub-Mk1\iRonCub\
set YARP_DATA_DIRS=%YARP_DATA_DIRS%;%IRONCUB_COMPONENT_SOURCE_DIR%\models\iRonCub-Mk1_1\iRonCub\
```

Set the `YARP_ROBOT_NAME` variable as the name of the folder where the `model.urdf` is stored.
- `set YARP_ROBOT_NAME=iRonCub-Mk1_Gazebo` for using `iRonCub Mk1` with **Gazebo**
- `set YARP_ROBOT_NAME=iRonCub-Mk1_1_Gazebo` for using `iRonCub Mk1_1` with **Gazebo**

### How to launch the yarpmotorgui (on Linux)

``` bash
cd ${COMPONENT_IRONCUB_PREFIX}/component_ironcub/models/home-poses
yarpmotorgui --from {NAME_HOMEPOSE.ini}
```

### How to launch the yarpmotorgui (on Windows)

``` cmd
cd %IRONCUB_COMPONENT_SOURCE_DIR%\models\home-poses
yarpmotorgui --from {NAME_HOMEPOSE.ini}
```

### How to run the yarprobotinterface (on both Linux and Windows)

You can use the following command:
``` bash
yarprobotinterface --config launch-wholebodydynamics-iRonCub.xml
```
(**warning:** by default the FT sensors offsets are set to zero by ```<param name="startWithZeroFTSensorOffsets">true</param>``` [here](./iRonCub-Mk1/iRonCub/robots/iRonCub-Mk1_Gazebo/estimators/wholebodydynamics-external-iRonCub.xml#L18) for `iRonCub-Mk1_Gazebo` model and [here](./iRonCub-Mk1_1/iRonCub/robots/iRonCub-Mk1_1_Gazebo/estimators/wholebodydynamics-external-iRonCub.xml#L18) for `iRonCub-Mk1_1_Gazebo` model)

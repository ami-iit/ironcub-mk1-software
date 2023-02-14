# iRonCub models

The URDF models have been developed starting from the [iCub 2.5 models](https://github.com/robotology/icub-models/tree/master/iCub/robots). More in details, the same files have been copied and adapted to generate the iRonCub models.

**Versions:**

Name | Model | Description
:-------------------------:|:-------------------------:|:-------------------------:
`iRonCub Mk1` | <img src="https://user-images.githubusercontent.com/12396934/218821834-02fd6640-1772-441d-9a6d-eca258db1ba3.png" width="200" height="350" /> | it's the first iRonCub version.
`iRonCub Mk1_1` | <img src="https://user-images.githubusercontent.com/12396934/218819957-0a8ef0eb-da94-40b3-a16d-b51596c79427.png" width="200" height="350" /> | it's an intermediate version after iRonCub Mk1 version.

## Installation and usage

#### How to use models in Gazebo (on Linux)

You should add these lines in your `.bashrc` (**warning**! not needed if you source the `setup.sh` file as described in this [README](../README.md#setup-the-enviroment))

``` bash
export IRONCUB_SOFTWARE_SOURCE_DIR=[path where this repository is stored]
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${IRONCUB_SOFTWARE_SOURCE_DIR}/models/
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${IRONCUB_SOFTWARE_SOURCE_DIR}/models/iRonCub-Mk1/iRonCub/robots
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${IRONCUB_SOFTWARE_SOURCE_DIR}/models/iRonCub-Mk1_1/iRonCub/robots
```

#### How to use models in Gazebo (on Windows)

You should add these lines in your custom `.bat` file to be called from terminal (**warning**! not needed if you call the `setup.bat` file as described in this [README](../README.md#create-the-setupbat-file))

``` cmd
set IRONCUB_SOFTWARE_SOURCE_DIR=[path where this repository is stored]
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_SOFTWARE_SOURCE_DIR%\models\
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_SOFTWARE_SOURCE_DIR%\models\iRonCub-Mk1\iRonCub\robots
set GAZEBO_MODEL_PATH=%GAZEBO_MODEL_PATH%;%IRONCUB_SOFTWARE_SOURCE_DIR%\models\iRonCub-Mk1_1\iRonCub\robots
```

#### How to use the .urdf model with WBToolbox and Simulink (on Linux)

You should add these lines in your `.bashrc` (**warning**! not needed if you source the `setup.sh` file as described in this [README](../README.md#setup-the-enviroment))

``` bash
export IRONCUB_SOFTWARE_SOURCE_DIR=[path where this repository is stored]
export YARP_DATA_DIRS=${YARP_DATA_DIRS}:${IRONCUB_SOFTWARE_SOURCE_DIR}/models/iRonCub-Mk1/iRonCub/
export YARP_DATA_DIRS=${YARP_DATA_DIRS}:${IRONCUB_SOFTWARE_SOURCE_DIR}/models/iRonCub-Mk1_1/iRonCub/
```

Set the `YARP_ROBOT_NAME` variable as the name of the folder where the `model.urdf` is stored.
- `export YARP_ROBOT_NAME=iRonCub-Mk1_Gazebo_v1` for using `iRonCub Mk1` with **Gazebo**
- `export YARP_ROBOT_NAME=iRonCub-Mk1_1_Gazebo_v1` for using `iRonCub Mk1_1` with **Gazebo**

#### How to use the .urdf model with WBToolbox and Simulink (on Windows)
You should add these lines in your custom `.bat` file to be called from terminal (**warning**! not needed if you call the `setup.bat` file as described in this [README](../README.md#create-the-setupbat-file))

``` cmd
set IRONCUB_SOFTWARE_SOURCE_DIR=[path where this repository is stored]
set YARP_DATA_DIRS=%YARP_DATA_DIRS%;%IRONCUB_SOFTWARE_SOURCE_DIR%\models\iRonCub-Mk1\iRonCub\
set YARP_DATA_DIRS=%YARP_DATA_DIRS%;%IRONCUB_SOFTWARE_SOURCE_DIR%\models\iRonCub-Mk1_1\iRonCub\
```

Set the `YARP_ROBOT_NAME` variable as the name of the folder where the `model.urdf` is stored.
- `set YARP_ROBOT_NAME=iRonCub-Mk1_Gazebo_v1` for using `iRonCub Mk1` with **Gazebo**
- `set YARP_ROBOT_NAME=iRonCub-Mk1_1_Gazebo_v1` for using `iRonCub Mk1_1` with **Gazebo**

#### How to launch the yarpmotorgui (on Linux)

``` bash
cd ${IRONCUB_SOFTWARE_SOURCE_DIR}/models/home-poses
yarpmotorgui --from {NAME_HOMEPOSE.ini}
```

#### How to launch the yarpmotorgui (on Windows)

``` cmd
cd %IRONCUB_SOFTWARE_SOURCE_DIR%\models\home-poses
yarpmotorgui --from {NAME_HOMEPOSE.ini}
```

#### How to run the yarprobotinterface (on both Linux and Windows)

You can use the following command:
``` bash
yarprobotinterface --config launch-wholebodydynamics-iRonCub.xml
```
(**warning:** by default the FT sensors offsets are set to zero by ```<param name="startWithZeroFTSensorOffsets">true</param>``` [here](./iRonCub-Mk1/iRonCub/robots/iRonCub-Mk1_Gazebo_v1/estimators/wholebodydynamics-external-iRonCub.xml#L18) for `iRonCub-Mk1_Gazebo_v1` model and [here](./iRonCub-Mk1_1/iRonCub/robots/iRonCub-Mk1_1_Gazebo_v1/estimators/wholebodydynamics-external-iRonCub.xml#L18) for `iRonCub-Mk1_1_Gazebo_v1` model).

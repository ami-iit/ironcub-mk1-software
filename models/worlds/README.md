# iRonCub worlds

Saved scenarios that can be loaded automatically from Gazebo without the need of setting manually, e.g., the robot position.

## Usage

To use the iRonCub worlds (tested only on Ubuntu): append to the `GAZEBO_RESOURCE_PATH` in your `.bashrc` the folders `iRonCub-Mk1_1_world` and `iRonCub-Mk1_world` as follows:

```
source /usr/share/gazebo/setup.sh
export GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH:$IRONCUB_SOFTWARE_SOURCE_DIR/models/world/iRonCub-Mk1_1_world

```

Once the words are added to Gazebo resurce path, call Gazebo followed by the name of the world file, e.g. `gazebo iRonCub_Mk1_1_world`.

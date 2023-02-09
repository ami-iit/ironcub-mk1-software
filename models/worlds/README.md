## iRonCub worlds

To use the iRonCub worlds (tested only on Ubuntu): append these lines to your `.bashrc` file:

```
source /usr/share/gazebo/setup.sh
export GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH:/PATH/WHERE/YOUR/WORLD/FILE/IS

```

That is, append to the `GAZEBO_RESOURCE_PATH` the folders `iRonCub-Mk0_playground` and `iRonCub-Mk1_playground`.

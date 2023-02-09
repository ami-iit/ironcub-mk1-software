### Available models:

- `iRonCub-Mk1_1`: model with no increased inertia;
  - `model_stl.urdf` -> model with stl meshes

- `iRonCub-Mk1_1_Gazebo`: model with increased inertia (for working inside Gazebo simulator);
  - `model.urdf` -> model with obj meshes
  - `model_stl.urdf` -> model with stl meshes

#### Fake Links (frames) added manually

Some links without properties, the so-called fake links, have been added manually in the `.yaml` without following the standard procedure.
If the cad of the robot will change, we need to update also the position of these links.
Here below a list:

- `base_link`
- `l_foot_dh_frame`
- `r_foot_dh_frame`
- `chest_realsense_frame`
- `root_link_imu_frame`

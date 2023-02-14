# Jet-plugin v1

Jets are simulated by a custom Gazebo plugin, called `jets-plugin-v1`. We consider as thrust the reaction force applied from the turbine to the robot link to witch the turbine is attached. The jets port should be easily usable with the WB-Toolbox block to read/write YARP ports.

### Usage

The plugin can be used in three different ways, depending on the cmake options with which it has been compiled:

|      cmake option       |     Description                                  |
| :---------------------: | :------------------------------------------------------: | 
| `USE_NONLINEAR_JET_DYNAMICS_PLUGIN` | when TRUE, the jets dynamics is simulated with a model obtained from experiment data, and assuming throttle as input. [1] |
| `USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN` | when TRUE, the jets dynamics is simulated with a simple integrator. The input is thrust derivative. |
|    | if both previuos options are FALSE, The input is assumed to be the thrust which is instantly set to Gazebo with no dynamics. |

### Description

The sdf elements child of `plugin` supported by this plugin are:

|      Element name       |                           Type                           |                                                           Description                                                            |                                  Example element line                                  |
| :---------------------: | :------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------: |
| `yarpConfigurationFile` | [Gazebo URI](https://bitbucket.org/osrf/gazebo/wiki/uri) | Location of the [YARP .ini configuration file](http://www.yarp.it/yarp_config_files.html) used to store parameters of the plugin | `<yarpConfigurationFile>model://flying-box-yarp/conf/jets.ini</yarpConfigurationFile>` |

The parameters supported by the plugin's `.ini` YARP configuration file are:

|              Parameter name               | SubParameter |      Type       |   Units   | Default Value | Required |                                                                                                 Description                                                                                                 | Notes |
| :---------------------------------------: | :----------: | :-------------: | :-------: | :-----------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :---: |
|              input-port-name              |      -       |     string      |     -     |       -       |   Yes    |                                                                                Port name used to read the input of the jets.                                                                                |       |
|             thrust-port-name              |      -       |     string      |     -     |       -       |   Yes    |                                                                     Port name used to publish the current thrust provided by the jets.                                                                      |       |
|             d_thrust-port-name              |      -       |     string      |     -     |       -       |   Yes    |                                                                     Port name used to publish the current thrust derivative.                                                                      |       |
|              max-thrust-in-N              |      -       | list of doubles |  Newton   |       -       |   Yes    |                                                                                Maximum value of thrust provided by each jet.                                                                                |       |
| inverse-time-constant-in-one-over-seconds |      -       |     double      | 1/seconds |       -       |   Yes    |                                                                    Inverse of the time constant of the first order dynamics of the jets (related to `USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN` option).                                                                    |       |
|                 link-jets                 |              | list of strings |     -     |       -       |   Yes    | List of SDF link names on which the jets are supposed to be attached. The force of the jet is supposed to be applied to the origin of the link frame, along the direction specified by the jet-axis option. |
|                 jet-axis                  |              | list of vectors |     -     |       -       |   Yes    |   List of the axis along with the thrust force is applied, expressed w.r.t. the link frame. For the moment, the force of the jet is supposed to be applied only along one of the axis of the link frame.    |
|               jet-coefficients                  |              | list of vectors |     -     |       -       |   Yes    |   List of the coefficients representing the dynamic model of the jet engines. For more details see also [1].    |

Example configuration file:

```ini
input-port-name /jets/input:i
thrust-port-name /jets/thrust:o
d_thrust-port-name /jets/d_thrust:o

link-jets (JETCAT_P200-RX_FR, JETCAT_P200-RX_FL, JETCAT_P200-RX_BR, JETCAT_P200-RX_BL)
max-thrust-in-N (63.0, 63.0, 220.0, 220.0)
jet-axis ((-1.0 0.0 0.0), (1.0 0.0 0.0), (0.0 0.0 -1.0), (0.0 0.0 -1.0))

# If the inverse of the time constant is 0.0, the jets are a pure integrator
inverse-time-constant-in-one-over-seconds 0.0

#  parameters-kero
jet-coefficients ((0.306530, -0.024867, -0.973422, 0.055786, 0.022618, 0.688710, 0.038025, -0.089879, -0.001393, -0.958953),
                  (0.306530, -0.024867, -0.973422, 0.055786, 0.022618, 0.688710, 0.038025, -0.089879, -0.001393, -0.958953),
                  (0.237755, -0.012799, -0.860374, 0.023606, 0.008599, 1.139026, 0.019914, -0.050257,  0.000302, -0.692913 ),
                  (0.237755, -0.012799, -0.860374, 0.023606, 0.008599, 1.139026, 0.019914, -0.050257,  0.000302, -0.692913 ))
```

The ports opened by the plugin are the following:

|     Port name      |      YARP type      | Unit of measurements |                                      Description                                       |
| :----------------: | :-----------------: | :------------------: | :------------------------------------------------------------------------------------: |
| `input-port-name`  | `yarp::sig::Vector` |       N,  N/s  or throttle %       |            Vector of size n_jets, defining the input to the jets dynamics.             |
| `thrust-port-name` | `yarp::sig::Vector` |          N            | Vector of size n_jets, reporting the current value of the thrust provided by the jets. |
| `d_thrust-port-name` | `yarp::sig::Vector` |        N/s           | Vector of size n_jets, reporting the current value of the thrust derivative. |

### References

```
@ARTICLE{8977379,
  author={L’Erario, Giuseppe and Fiorio, Luca and Nava, Gabriele and Bergonti, Fabio and Mohamed, Hosameldin Awadalla Omer and Benenati, Emilio and Traversaro, Silvio and Pucci, Daniele},
  journal={IEEE Robotics and Automation Letters}, 
  title={Modeling, Identification and Control of Model Jet Engines for Jet Powered Robotics}, 
  year={2020},
  volume={5},
  number={2},
  pages={2070-2077},
  doi={10.1109/LRA.2020.2970572}}

```


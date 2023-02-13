# Simulink library for iRonCub flight control

It is a library of Simulink blocks (and the associated MATLAB functions) used in the iRonCub flight control and shared among the team members. **Currently supported minimum version: MATLAB 2020a, Simulink 10.1**.

## Overview

The library will appear in the Simulink Library Browser with the name specified inside [slblocks.m](slblocks.m). The main library folder is divided into subfolders. Each subfolder has a main model -- see [momentum_flight_control_sublib](momentum_flight_control/momentum_flight_control_sublib.slx). Each library element in the subfolders is contained in the subfolder main model. Then, each subfolder main model is linked to `ironcub_lib_main.slx`;

## Installation and usage

The models and associated Matlab functions are installed in the `$CMAKE_INSTALL_PREFIX/lib/simulink` folder.

To enable it, you need to set `INSTALL_SIMULINK_LIBRARY=ON` in the `cmake` options.
Type `ccmake ..` in a terminal in the build folder, search for this option and enable it.

To use the MATLAB functions that are installed with the library, the function name must be preceded by the namespace `iRonCubLib`. E.g. `[] = iRonCubLib.myLibraryFunction()`.

## How to link new elements to the (sub)libraries

- open the (sub)library (e.g., `ironcub_lib_main.slx`);

- create a new subsystem and remove in/out elements;

- in the subsystem's property (right click on it to access), select `callbacks/openfcn`;

- add the name of the sublibrary model to be linked by the subsystem;

Now `ironcub_lib_main.slx` links to your library model as a sublib in the Simulink Library Browser.

## List of available sublibraries

- [data dumper](data_dumper)

- [filters](filters)

- [forward_dynamics](forward_dynamics)

- [jets_control](jets_control)

- [momentum_flight_control](momentum_flight_control/README.md)

- [realSense_base_estimation](realSense_base_estimation)

- [vive_base_estimation](vive_base_estimation/README.md)

- [thrust_estimation](thrust_estimation/README.md)

- [turbine_set_references](turbine_set_references)

- [turbine_get_measurement](turbine_get_measurement)

- [Visualizer++](Visualizer++)

- [visualizerMatlab](visualizerMatlab)

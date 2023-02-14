# Simulink library for iRonCub flight control

It is a library of Simulink blocks (and the associated MATLAB functions) used in the iRonCub flight control and shared among the different controllers. **Currently supported minimum version: MATLAB 2021b, Simulink 10.4**.

## Overview

The library will appear in the Simulink Library Browser with the name specified inside [slblocks.m](slblocks.m). The main library folder is divided into subfolders. Each subfolder has a main model -- see [momentum_flight_control](momentum_flight_control/momentum_flight_control_v1.slx). Each library element in the subfolders is contained in the subfolder main model. Then, each subfolder main model is linked to [ironcub_lib_main_v1](ironcub_lib_main_v1.slx).

## Installation and usage

The models and associated Matlab functions are installed in the `$CMAKE_INSTALL_PREFIX/lib/simulink_v1` folder.

To enable it, you need to set `INSTALL_SIMULINK_LIBRARY=ON` in the `cmake` options. Type `ccmake ..` in a terminal in the build folder, search for this option and enable it.

To use the MATLAB functions that are installed with the library, the function name must be preceded by the namespace `iRonCubLib_v1`. E.g. `[] = iRonCubLib_v1.myLibraryFunction()`.

## How to link new elements to the (sub)libraries

- open the (sub)library (e.g., `ironcub_lib_main_v1.slx`);

- create a new subsystem and remove in/out elements;

- in the subsystem's property (right click on it to access), select `callbacks/openfcn`;

- add the name of the sublibrary model to be linked by the subsystem;

Now `ironcub_lib_main_v1.slx` links to your library model as a sublib in the Simulink Library Browser.

## List of available sublibraries

- [jets_control](jets_control)

- [momentum_flight_control](momentum_flight_control)

- [thrust_estimation](thrust_estimation)

- [visualizer++](visualizer++)

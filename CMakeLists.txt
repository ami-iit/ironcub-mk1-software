################################################################################
#                                                                              #
# Copyright (C) 2018 Fondazione Istitito Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
#                                                                              #
################################################################################

cmake_minimum_required(VERSION 3.5)
project(ironcub
        VERSION 0.0.1
        LANGUAGES C CXX)

option(INSTALL_IRONCUB_MODELS "Install iRonCub models in CMAKE_INSTALL_PREFIX." TRUE)
option(INSTALL_LIBRARY "Install iRonCub gazebo plugin and simulink library." TRUE)

if(INSTALL_SOFTWARE)
    option(USE_NONLINEAR_JET_DYNAMICS_PLUGIN "Install the nonlinear dynamics of the jet" FALSE)
    option(USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN "Install the firstorder dynamics of the jet" TRUE)
    set(FULLPATH_IRONCUB_EXPERIMENT_STORAGE "" CACHE STRING "Full path ironcub experiment storage")
    add_subdirectory(lib)
endif()

add_subdirectory(models)

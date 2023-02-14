# ###############################################################################
# #
# Copyright (C) 2018 Fondazione Istituto Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
# #
# ###############################################################################

link_directories(${GAZEBO_LIBRARY_DIRS})

if(USE_NONLINEAR_JET_DYNAMICS_PLUGIN AND NOT USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN)
        add_definitions(-DDYNTYPE="nonlinear_dynamics")
        message(STATUS "Installing non-linear jet dynamics plugin.")
        add_library(jets-plugin-v1 SHARED jet-plugin.h jets-plugin.cc)
elseif(USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN AND NOT USE_NONLINEAR_JET_DYNAMICS_PLUGIN)
        add_definitions(-DDYNTYPE="first_order_dynamics")
        message(STATUS "Installing first order jet dynamics plugin.")
        add_library(jets-plugin-v1 SHARED jet-plugin.h jets-plugin.cc)
elseif(USE_FIRST_ORDER_JET_DYNAMICS_PLUGIN AND USE_NONLINEAR_JET_DYNAMICS_PLUGIN)
        message(FATAL_ERROR "Choose just one option for the jet dynamics ore none to set directly the thrust.")
else()
        add_definitions(-DDYNTYPE="no_dynamics")
        message(STATUS "Installing no dynamics plugin.")
        add_library(jets-plugin-v1 SHARED jet-plugin.h jets-plugin.cc)
endif()

target_include_directories(jets-plugin-v1 PRIVATE ${GAZEBO_INCLUDE_DIRS})

target_include_directories(jets-plugin-v1 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

target_link_libraries(jets-plugin-v1 ${GAZEBO_LIBRARIES} ${YARP_LIBRARIES})
install(TARGETS jets-plugin-v1
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")


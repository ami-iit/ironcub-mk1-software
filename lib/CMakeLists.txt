################################################################################
#                                                                              #
# Copyright (C) 2018 Fondazione Istituto Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
#                                                                              #
################################################################################

# Find dependencies
find_package(YARP REQUIRED)
find_package(gazebo REQUIRED)
if (gazebo_VERSION_MAJOR LESS 8.0)
	message(status "Gazebo version : " ${gazebo_VERSION_MAJOR}.${gazebo_VERSION_MINOR}.${gazebo_VERSION_PATCH})
	message(FATAL_ERROR "Your Gazebo version is older than Gazebo 8.0. The jets plugin is supported with gazebo version >= 8.0. Please update to a newer version")
endif()

# Set output directories for build artifacts
include(GNUInstallDirs)


# Create build artifacts in ${build}/bin for binaries and ${build}/lib for libraries
# This simplifies the use of simulation model directly from the build directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")

add_subdirectory(gazebo)
add_subdirectory(simulink)


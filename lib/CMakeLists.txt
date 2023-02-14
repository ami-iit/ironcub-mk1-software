################################################################################
#                                                                              #
# Copyright (C) 2018 Fondazione Istituto Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
#                                                                              #
################################################################################

############################# GAZEBO PLUGIN ###################################

# Find dependencies
find_package(YARP REQUIRED)
find_package(gazebo REQUIRED)
if (gazebo_VERSION_MAJOR LESS 8.0)
	message(status "Gazebo version : " ${gazebo_VERSION_MAJOR}.${gazebo_VERSION_MINOR}.${gazebo_VERSION_PATCH})
	message(FATAL_ERROR "Your Gazebo version is older than Gazebo 8.0. The jets plugin is supported with gazebo version >= 8.0. Please update to a newer version")
endif()

# Set output directories for build artifacts
include(GNUInstallDirs)

# Add plugin to Gazebo plugin path
set(SETUP_PATH_GAZEBO_PLUGINS "${EXPORT_VAR} GAZEBO_PLUGIN_PATH=${VARIABLE_START}GAZEBO_PLUGIN_PATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}${PLUGIN_FOLDER_NAME}")

# Create build artifacts in ${build}/bin for binaries and ${build}/lib for libraries
# This simplifies the use of simulation model directly from the build directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")

add_subdirectory(gazebo)

############################# SIMULINK LIBRARY #################################

add_subdirectory(simulink)

set(SETUP_PATH_SIMULINK_LIBRARY "
	${EXPORT_VAR} MATLABPATH=${VARIABLE_START}MATLABPATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}lib${PATH_SEPARATOR}simulink_v1${PATH_SEPARATOR}
	${EXPORT_VAR} MATLABPATH=${VARIABLE_START}MATLABPATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}lib${PATH_SEPARATOR}simulink_v1${PATH_SEPARATOR}matlab_src${PATH_SEPARATOR}
	${EXPORT_VAR} MATLABPATH=${VARIABLE_START}MATLABPATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}lib${PATH_SEPARATOR}simulink_v1${PATH_SEPARATOR}conf${PATH_SEPARATOR}
	${EXPORT_VAR} BLOCKFACTORY_PLUGIN_PATH=${VARIABLE_START}BLOCKFACTORY_PLUGIN_PATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}${PLUGIN_FOLDER_NAME}
	${EXPORT_VAR} YARP_DATA_DIRS=${VARIABLE_START}YARP_DATA_DIRS${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_SOURCE_DIR${VARIABLE_END}${PATH_SEPARATOR}software${PATH_SEPARATOR}simulink_v1${PATH_SEPARATOR}visualizer++${PATH_SEPARATOR}conf
       ${EXPORT_VAR} PATH=${VARIABLE_START}PATH${VARIABLE_END}${PATH_LIST_SEPARATOR}${VARIABLE_START}IRONCUB_SOFTWARE_INSTALL_PREFIX${VARIABLE_END}${PATH_SEPARATOR}bin")
If(UNIX)
	set(SETUP_PATH_SIMULINK_LIBRARY "${SETUP_PATH_SIMULINK_LIBRARY} 
	${EXPORT_VAR} MESA_LOADER_DRIVER_OVERRIDE=i965")
endif()


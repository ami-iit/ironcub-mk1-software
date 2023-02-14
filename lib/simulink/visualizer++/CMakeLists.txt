set(LIBRARY_TARGET_NAME Visualizer_v1)

# # C++ standard
# set(CMAKE_CXX_STANDARD 14)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)

# # Export all symbols in Windows
# set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Utility for defining install folders
include(GNUInstallDirs)

# Tweak linker flags in Linux.
# Matlab is very strict on missing symbols and by default ld do not warn if
# something is missing.
if(UNIX AND NOT APPLE)
    get_filename_component(LINKER_BIN ${CMAKE_LINKER} NAME)
    if(${LINKER_BIN} STREQUAL "ld")
        set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--unresolved-symbols=report-all")
    endif()
endif()

# ===========
# C++ LIBRARY
# ===========

# Find the needed BlockFactory components:
# - "Core" contains the core classes such as Block and Signal
# - "Simulink" is required at runtime for loading the library from Simulink
find_package(BlockFactory
    REQUIRED COMPONENTS Core
    OPTIONAL_COMPONENTS Simulink)
find_package(iDynTree)
find_package(Eigen3)
find_package(YARP)

add_library(Visualizer_v1 SHARED
    include/Visualizer/Visualizer.h
    src/Visualizer.cpp
    src/Factory.cpp)

# Manually set the name of the output library. This is not required and it
# is done only for sake of clarity.
set_target_properties(Visualizer_v1 PROPERTIES
    OUTPUT_NAME "Visualizer_v1")

# Link the library with the Core component containing the core classes
target_link_libraries(Visualizer_v1 PRIVATE
    BlockFactory::Core
    iDynTree::idyntree-visualization
    iDynTree::idyntree-modelio
    iDynTree::idyntree-core
    YARP::YARP_OS
    Eigen3::Eigen)

# Setup the include directories
target_include_directories(Visualizer_v1 PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)

install(TARGETS Visualizer_v1
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")


install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/conf/iRonCubVisualizer_v1.ini
    DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink_v1/conf/)

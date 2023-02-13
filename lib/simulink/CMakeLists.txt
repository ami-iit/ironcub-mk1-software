################################################################################
#                                                                              #
# Copyright (C) 2018 Fondazione Istitito Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
#                                                                              #
################################################################################

# Add here the subfolders with sublibraries
add_subdirectory(Visualizer++)

# Install the Simulink models into the install folder
file(GLOB slx_files "*.slx")
install(FILES ${slx_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink)

# Install the MATLAB script into the install folder
file(GLOB m_files "*.m")
install(FILES ${m_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink)

################################################################################

# Install the sublibraries related files into the install folder

macro(INSTALL_SUBLIBMFILES curdir)
# This macro installs all the matlab files inside the specified folder into the install folder
  file(GLOB children RELATIVE ${curdir} ${curdir}/src/*)
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
      get_filename_component(child_dir_name ${curdir}/${child} NAME)
      if(${child_dir_name} MATCHES "^@" OR ${child_dir_name} MATCHES "\\+") #if the directory starts with '@' or '+' (a matlab class or a namespace)
        install(DIRECTORY ${curdir}/${child} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink/matlab_src/+iRonCubLib_v1) # install the whole directory
      else()
        # This applies to the folders inside this directory <sublib_dir>/src are assumed to contain matlab files
        file(GLOB m_files ${curdir}/${child}/*.m)
        install(FILES ${m_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink/matlab_src/+iRonCubLib_v1) # install the .m files within this directory
      endif()
    endif()
  endforeach()
  # The following applies to the matlab files inside this directory <sublib_dir>/src
  file(GLOB m_files_out ${curdir}/src/*.m)
  install(FILES ${m_files_out} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink/matlab_src/+iRonCubLib_v1)
endmacro()

macro(INSTALL_SUBLIBS curdir)
  file(GLOB sublibs_dirs RELATIVE ${curdir} ${curdir}/*)
  foreach(sublib_dir ${sublibs_dirs})
    if(IS_DIRECTORY ${curdir}/${sublib_dir})
      # Install the Simulink models inside each sublibrary folder into the install folder
      file(GLOB sublib_slx_files ${sublib_dir}/*.slx)
      install(FILES ${sublib_slx_files} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/simulink)
      # Install Matlab files inside each sublibrary folder into the install folder
      INSTALL_SUBLIBMFILES(${CMAKE_CURRENT_SOURCE_DIR}/${sublib_dir})
    endif()
  endforeach()
endmacro()

INSTALL_SUBLIBS(${CMAKE_CURRENT_SOURCE_DIR})


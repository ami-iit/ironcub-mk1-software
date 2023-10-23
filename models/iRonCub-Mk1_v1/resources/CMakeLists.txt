find_package(PythonInterp REQUIRED)

# Generate URDF models for
# iRonCub robots using the simmechanics-to-urdf script
macro(generate_iRonCub_simmechanics)
    set(options INCREASE_INERTIA_FOR_GAZEBO REMOVE_FEET_FT_SENSORS)
    set(oneValueArgs YARP_ROBOT_NAME SIMMECHANICS_XML YAML_TEMPLATE CSV_TEMPLATE MODEL_URDF_NAME MESH_FORMAT_EXTENSION)
    set(multiValueArgs)
    cmake_parse_arguments(GIVTWO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Generate the YAML file from the CMake configuration
    set(CHEST_ASSIGNED_MASS 11.145012)
    if(GIVTWO_INCREASE_INERTIA_FOR_GAZEBO)
      set(GAZEBO_ASSIGNED_INERTIAS
"assignedInertias:
  - linkName: r_hip_3
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: r_ankle_2
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_hip_3
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_ankle_2
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: r_shoulder_1
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: r_shoulder_2
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: r_shoulder_3
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: r_elbow_1
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_shoulder_1
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_shoulder_2
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_shoulder_3
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: l_elbow_1
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: neck_1
    xx: 0.01
    yy: 0.01
    zz: 0.01
  - linkName: neck_2
    xx: 0.01
    yy: 0.01
    zz: 0.01
")
      set(LOWERBODY_JOINT_DAMPING 1.0)
      set(UPPERBODY_JOINT_DAMPING 1.0)
      set(ASSIGNED_COLLISION_GEOMETRIES
"assignedCollisionGeometry:
  - linkName: r_foot
    geometricShape:
      shape: box
      size: 0.16 0.072 0.001
      origin: \"0.03 0.005 0.014 0.0 0.0 0.0\"
  - linkName: l_foot
    geometricShape:
      shape: box
      size: 0.16 0.072 0.001
      origin: \"0.03 -0.005 0.014 0.0 0.0 0.0\"
")
    else()
      set(GAZEBO_ASSIGNED_INERTIAS "")
      set(LOWERBODY_JOINT_DAMPING 0.223)
      set(UPPERBODY_JOINT_DAMPING 0.06)
      set(ASSIGNED_COLLISION_GEOMETRIES "")
    endif()

    set(MESH_FILE_FORMAT "filenameformatchangeext: \"package://iRonCub-Mk1_v1/iRonCub/meshes/${GIVTWO_MESH_FORMAT_EXTENSION}/%s.${GIVTWO_MESH_FORMAT_EXTENSION}\"")
    set(CONF_FILE_DIR "iRonCub-Mk1_v1/iRonCub/conf")
    set(ANKLE_PITCH_ROM "-35,35")
    set(REVERSE_ROTATION_AXIS
"reverseRotationAxis:
  l_shoulder_roll
  l_elbow
  l_hip_yaw
  l_knee
  l_ankle_pitch
  r_hip_pitch
  r_ankle_roll
  r_shoulder_pitch
  r_shoulder_yaw
  torso_pitch
  neck_roll
")

  if(GIVTWO_REMOVE_FEET_FT_SENSORS)
    set(FEET_FT_SENSORS "")
    SET(STR_FEET_FT_SENSORS "no-feet-ft")
  else()
    set(FEET_FT_SENSORS 
    "  - jointName: l_foot_ft_sensor
    directionChildToParent: Yes
    sensorBlobs:
    - |
        <plugin name=\"left_foot_ft_plugin\" filename=\"libgazebo_yarp_forcetorque.so\">
          <yarpConfigurationFile>model://${CONF_FILE_DIR}/FT/gazebo_icub_left_foot_ft.ini</yarpConfigurationFile>
        </plugin>
  - jointName: r_foot_ft_sensor
    directionChildToParent: Yes
    sensorBlobs:
    - |
        <plugin name=\"right_foot_ft_plugin\" filename=\"libgazebo_yarp_forcetorque.so\">
          <yarpConfigurationFile>model://${CONF_FILE_DIR}/FT/gazebo_icub_right_foot_ft.ini</yarpConfigurationFile>
        </plugin>")
    SET(STR_FEET_FT_SENSORS "feetFt")
  endif()

    set(GENERATED_YAML_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${GIVTWO_YARP_ROBOT_NAME}_${GIVTWO_MESH_FORMAT_EXTENSION}_${STR_FEET_FT_SENSORS}.yaml)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/data/${GIVTWO_YAML_TEMPLATE}
                   ${GENERATED_YAML_LOCATION}
                   @ONLY)
    set(GENERATED_CSV_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${GIVTWO_YARP_ROBOT_NAME}.csv)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/data/${GIVTWO_CSV_TEMPLATE}
                   ${GENERATED_CSV_LOCATION}
                   @ONLY)

    add_custom_command(OUTPUT ${GIVTWO_YARP_ROBOT_NAME}_${GIVTWO_MESH_FORMAT_EXTENSION}_${STR_FEET_FT_SENSORS}.urdf
                       COMMAND simmechanics_to_urdf
                       ARGS ${CMAKE_CURRENT_SOURCE_DIR}/data/${GIVTWO_SIMMECHANICS_XML}
                            --output xml
                            --yaml ${GENERATED_YAML_LOCATION}
                            --csv-joints ${GENERATED_CSV_LOCATION}
                            --outputfile ${GIVTWO_YARP_ROBOT_NAME}_${GIVTWO_MESH_FORMAT_EXTENSION}_${STR_FEET_FT_SENSORS}.urdf
                       MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/data/${GIVTWO_SIMMECHANICS_XML}"
                       DEPENDS  "${GENERATED_YAML_LOCATION}"
                                "${GENERATED_CSV_LOCATION}")
    add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/${BUILD_PREFIX}/robots/${GIVTWO_YARP_ROBOT_NAME}/${GIVTWO_MODEL_URDF_NAME}"
                           MAIN_DEPENDENCY "${GIVTWO_YARP_ROBOT_NAME}_${GIVTWO_MESH_FORMAT_EXTENSION}_${STR_FEET_FT_SENSORS}.urdf"
                           COMMAND ${CMAKE_COMMAND} -E
                                   copy "${GIVTWO_YARP_ROBOT_NAME}_${GIVTWO_MESH_FORMAT_EXTENSION}_${STR_FEET_FT_SENSORS}.urdf" "${CMAKE_BINARY_DIR}/../${BUILD_PREFIX}/robots/${GIVTWO_YARP_ROBOT_NAME}/${GIVTWO_MODEL_URDF_NAME}")

    list(APPEND model-simmechanics-generated-models "${CMAKE_BINARY_DIR}/${BUILD_PREFIX}/robots/${GIVTWO_YARP_ROBOT_NAME}/${GIVTWO_MODEL_URDF_NAME}")
endmacro()

set(model-simmechanics-generated-models "")

generate_iRonCub_simmechanics(YARP_ROBOT_NAME iRonCub-Mk1_Gazebo
                              SIMMECHANICS_XML "IRONCUB-MK1_SIM_MODEL.xml"
                              YAML_TEMPLATE "IRONCUB-MK1_simmechanics_options.yaml.in"
                              CSV_TEMPLATE "IRONCUB-MK1_joint_parameters.csv.in"
                              MODEL_URDF_NAME "model.urdf"
                              MESH_FORMAT_EXTENSION "obj"
                              INCREASE_INERTIA_FOR_GAZEBO)

generate_iRonCub_simmechanics(YARP_ROBOT_NAME iRonCub-Mk1_Gazebo
                              SIMMECHANICS_XML "IRONCUB-MK1_SIM_MODEL.xml"
                              YAML_TEMPLATE "IRONCUB-MK1_simmechanics_options.yaml.in"
                              CSV_TEMPLATE "IRONCUB-MK1_joint_parameters.csv.in"
                              MODEL_URDF_NAME "model_stl.urdf"
                              MESH_FORMAT_EXTENSION "stl"
                              INCREASE_INERTIA_FOR_GAZEBO)

generate_iRonCub_simmechanics(YARP_ROBOT_NAME iRonCub-Mk1
                              SIMMECHANICS_XML "IRONCUB-MK1_SIM_MODEL.xml"
                              YAML_TEMPLATE "IRONCUB-MK1_simmechanics_options.yaml.in"
                              CSV_TEMPLATE "IRONCUB-MK1_joint_parameters.csv.in"
                              MODEL_URDF_NAME "model.urdf"
                              MESH_FORMAT_EXTENSION "obj")

generate_iRonCub_simmechanics(YARP_ROBOT_NAME iRonCub-Mk1
                              SIMMECHANICS_XML "IRONCUB-MK1_SIM_MODEL.xml"
                              YAML_TEMPLATE "IRONCUB-MK1_simmechanics_options.yaml.in"
                              CSV_TEMPLATE "IRONCUB-MK1_joint_parameters.csv.in"
                              MODEL_URDF_NAME "model_stl.urdf"
                              MESH_FORMAT_EXTENSION "stl")

add_custom_target(generate-models-simmechanics-Mk1
                  ALL
                  DEPENDS ${model-simmechanics-generated-models})

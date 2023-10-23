# Copyright: (C) 2018 iCub Facility - Fondazione Istituto Italiano di Tecnologia
# CopyPolicy: Released under the terms of the GNU LGPL v2+.

if(ENABLE_MK1_MODEL_GENERATION)
	project(ironcub-model-generator)

	# Give error if add_dependencies is called on a non-existing target
	if(POLICY CMP0046)
	  cmake_policy(SET CMP0046 NEW)
	endif()

	set(BUILD_PREFIX "models/iRonCub-Mk1_v1/iRonCub")
	add_subdirectory(resources)

	add_custom_target(generate-models-Mk1 ALL)

	add_dependencies(generate-models-Mk1 generate-models-simmechanics-Mk1)
endif()

add_subdirectory(iRonCub)

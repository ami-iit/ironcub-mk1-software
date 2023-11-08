# Copyright: (C) 2018 iCub Facility - Fondazione Istituto Italiano di Tecnologia

if(INSTALL_IRONCUB_MODELS)
	set(robotname iRonCub-Mk1)
	install(FILES robots/${robotname}/model_stl.urdf DESTINATION ${CMAKE_INSTALL_PREFIX}/share/iCub/robots/${robotname})
	install(FILES robots/${robotname}/model.urdf DESTINATION ${CMAKE_INSTALL_PREFIX}/share/iCub/robots/${robotname})
	
	set(robotname iRonCub-Mk1_Gazebo)
	install(FILES robots/${robotname}/launch-wholebodydynamics-iRonCub.xml DESTINATION ${CMAKE_INSTALL_PREFIX}/share/yarp/robots/${robotname})
	install(FILES robots/${robotname}/estimators/wholebodydynamics-external-iRonCub.xml DESTINATION ${CMAKE_INSTALL_PREFIX}/share/yarp/robots/${robotname}/estimators/)
endif()

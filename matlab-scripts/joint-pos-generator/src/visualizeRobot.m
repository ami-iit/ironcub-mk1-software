function [] = visualizeRobot(KinDynModel, jointPos, Config)
      
    % set the path of robot meshes
    sourceDirPath = getenv('IRONCUB_SOFTWARE_SOURCE_DIR');
    meshesPath    = [sourceDirPath,'/models'];

    % set the current robot pose
    updateRobotState(jointPos, KinDynModel, Config.Model.gravityAcc, Config.Model.ndof);

    % prepare MATLAB figure
    iDynTreeWrappers.prepareVisualization(KinDynModel, meshesPath, 'color', [0.9,0.9,0.9], 'material', 'metal', ...
                                         'transparency', 1, 'debug', true, 'view', [-92.9356 22.4635],...
                                         'groundOn', true, 'groundColor', [0.5 0.5 0.5], 'groundTransparency', 0.5);
end

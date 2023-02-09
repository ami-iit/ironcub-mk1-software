function [] = visualizeRobot(KinDynModel, uStar)
   
    % VISUALIZEROBOT visualizes the robot in the optimized pose.
    %
    % FORMAT:  [] = visualizeRobot(KinDynModel, uStar)
    %
    % INPUTS:  - KinDynModel: a structure containing the loaded model and additional info;
    %          - uStar: [6+ndof+njets x 1] optimization output;
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Sept 2020
    %
    % Modified Dec 2021

    %% ------------Initialization----------------
    
    % set the path of robot meshes (hard-coded for the moment)
    meshesPath = '/home/gnava/Software/github/ami-iit/component_ironcub/models';

    % get robot pose
    basePos  = uStar(1:3);
    w_H_b    = wbc.fromPosRpyToTransfMatrix([basePos; uStar(4:6)]);
    jointPos = uStar(7:end-4);

    % set initial robot pose
    iDynTreeWrappers.setRobotState(KinDynModel, w_H_b, jointPos, zeros(6,1), zeros(size(jointPos)), [0,0,-9.81]);

    % prepare MATLAB figure
    iDynTreeWrappers.prepareVisualization(KinDynModel, meshesPath, 'color', [0.9,0.9,0.9], 'material', 'metal', ...
                                         'transparency', 1, 'debug', true, 'view', [-92.9356   22.4635],...
                                         'groundOn', true, 'groundColor', [0.5 0.5 0.5], 'groundTransparency', 0.5);
end

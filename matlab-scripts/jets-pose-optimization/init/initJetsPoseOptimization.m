% INITJETSPOSEOPTIMIZATION initializes the jets pose optimization simulation.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

Config.Model.modelName    = 'model_jetsOptimization.urdf';
Config.Model.modelPath    = './model/';

% select the link that will be used as base link
Config.Model.baseLinkName = 'root_link';

% specify the list of joints that are going to be considered in the reduced model
Config.Model.jointList    = {'torso_pitch','torso_roll','torso_yaw',...
                             'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow','l_wrist_prosup', ...
                             'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow','r_wrist_prosup', ...
                             'l_hip_pitch','l_hip_roll','l_hip_yaw','l_knee','l_ankle_pitch','l_ankle_roll', ...
                             'r_hip_pitch','r_hip_roll','r_hip_yaw','r_knee','r_ankle_pitch','r_ankle_roll'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Jets pose optimization demo setup %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [ 5  0  0];                 
left_arm_Position  = [-20 30 50  15 15];           
right_arm_Position = [-20 30 50  15 15];                
left_leg_Position  = [ 0  0  0  0  0  0];
right_leg_Position = [ 0  0  0  0  0  0]; 

Config.initJetsPoseOpt.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initJetsPoseOpt.jointVel_init = zeros(length(Config.initJetsPoseOpt.jointPos_init),1);
Config.initJetsPoseOpt.gravityAcc    = [0;0;-9.81];

% number of the tests to be performed. It can be a also a vector
Config.initJetsPoseOpt.testNumbersVector = 1:4; %1:16;

% optimization: perform random joints movements, with random thrust
% forces,for the time specified by tMax
Config.initJetsPoseOpt.tMax           = 100; % [s]
Config.initJetsPoseOpt.minThrust      = 10;  % [N]

Config.initJetsPoseOpt.jointPosLimits = [-20,  70; -30,  30;  -50,  50; ...                                     % torso
                                         -90,  10;  0,   160; -35,  80;  15,  105; -60,  60; ...                % larm
                                         -90,  10;  0,   160; -35,  80;  15,  105; -60,  60; ...                % rarm
                                         -35,  80; -15,  90;  -70,  70; -100, 0;   -30,  30; -20,  20; ...      % lleg
                                         -35,  80; -15,  90;  -70,  70; -100, 0;   -30,  30; -20,  20;]*pi/180; % rleg

% LOAD ROBOT_MK1 load the iRonCub-Mk1 robot model and set the robot initial
%                pose w.r.t. the inertial frame.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Sept. 2020
    
%% ------------Initialization----------------

% general parameters
DEBUG = false;

% specify the list of joints that are going to be considered in the reduced model
Config.Model.jointList    = {'torso_pitch','torso_roll','torso_yaw', ...
                             'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow', ...
                             'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow', ...
                             'l_hip_pitch','l_hip_roll','l_hip_yaw','l_knee','l_ankle_pitch','l_ankle_roll', ...
                             'r_hip_pitch','r_hip_roll','r_hip_yaw','r_knee','r_ankle_pitch','r_ankle_roll'};
        
% select the link that will be used as base link
Config.Model.baseLinkName = 'root_link';

% model name and path
Config.Model.modelName    = 'model_jointsOptimization_MK1.urdf';
Config.Model.modelPath    = './../model/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% turbines data structure init. %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate the TurbinesData structure
Config.TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine'};
Config.TurbinesData.turbineAxis   = [-3; -3; -3; -3];
Config.TurbinesData.njets         = length(Config.TurbinesData.turbineList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% set robot initial conditions %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [ 50 0  0];                 
left_arm_Position  = [-50 25 40 15];           
right_arm_Position = [-50 25 40 15];                
left_leg_Position  = [-20 10 5 -20 -10 -10];
right_leg_Position = [-20 10 5 -20 -10 -10]; 

Config.initJointPosOpt.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initJointPosOpt.jointVel_init = zeros(length(Config.initJointPosOpt.jointPos_init),1);
Config.initJointPosOpt.gravityAcc    = [0;0;-9.81];

% initial jets intensities
Config.initJointPosOpt.jetIntensities_init = [140; 140; 75; 75]; %[N]

% include fixed link constraints (feet fixed) in the optimization procedure
Config.initJointPosOpt.useFixedLinkConstraints = true;
Config.initJointPosOpt.fixOnlyHeightPitchRoll  = false;

% initial base pose w.r.t. the world frame
Config.initJointPosOpt.w_H_b_init = eye(4); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% load the robot model %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the reduced model
KinDynModel = iDynTreeWrappers.loadReducedModel(Config.Model.jointList, Config.Model.baseLinkName, ...
                                                Config.Model.modelPath, Config.Model.modelName, DEBUG); 

% set the initial robot position (no w_H_b set yet)
iDynTreeWrappers.setRobotState(KinDynModel, Config.initJointPosOpt.w_H_b_init, Config.initJointPosOpt.jointPos_init, ...
                               zeros(6,1), Config.initJointPosOpt.jointVel_init, Config.initJointPosOpt.gravityAcc);

% set the w_H_b transformation, assuming that the world frame is attached to the robot left foot                           
Config.initJointPosOpt.w_H_b_init = iDynTreeWrappers.getRelativeTransform(KinDynModel,'l_sole','root_link');

% set the initial robot state 
iDynTreeWrappers.setRobotState(KinDynModel, Config.initJointPosOpt.w_H_b_init, Config.initJointPosOpt.jointPos_init, ...
                               zeros(6,1), Config.initJointPosOpt.jointVel_init, Config.initJointPosOpt.gravityAcc);

% get the initial pose of the left and right foot (fixed links)
Config.initJointPosOpt.w_H_lFootInit = iDynTreeWrappers.getWorldTransform(KinDynModel,'l_sole');
Config.initJointPosOpt.w_H_rFootInit = iDynTreeWrappers.getWorldTransform(KinDynModel,'r_sole');

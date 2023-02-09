% LOAD ROBOT_MK1_1 load the iRonCub-Mk1_1 robot model and set the robot initial
%                  pose w.r.t. the inertial frame.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
%
% Genova, Sept. 2020
% Modified: Dec. 2021

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
Config.Model.modelName    = 'model_jointsOptimization_MK1_1.urdf';
Config.Model.modelPath    = './../model/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Load the turbine model %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Config.Model.turbineList  = {'l_arm_jet_turbine','r_arm_jet_turbine','chest_l_jet_turbine','chest_r_jet_turbine'};
Config.Model.turbineAxis  = [-3; -3; -3; -3];
Config.Model.njets        = length(Config.Model.turbineList);
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Load the robot model %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Config.Model.ndof         = length(Config.Model.jointList);
Config.Model.gravityAcc   = [0;0;-9.81];

% load the reduced model
KinDynModel = iDynTreeWrappers.loadReducedModel(Config.Model.jointList, Config.Model.baseLinkName, ...
                                                Config.Model.modelPath, Config.Model.modelName, DEBUG); 

% set the initial robot position
updateRobotState(zeros(Config.Model.ndof,1), KinDynModel, Config.Model.gravityAcc, Config.Model.ndof);
                           
% get the total mass of the robot
M = iDynTreeWrappers.getFreeFloatingMassMatrix(KinDynModel);
Config.Model.totalMass = M(1,1);

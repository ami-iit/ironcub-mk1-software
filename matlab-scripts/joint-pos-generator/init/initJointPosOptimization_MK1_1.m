% INITJOINTPOSOPTIMIZATION_MK1 initialization for the joint position optimization.
%                              This file is for the robot iRonCub-Mk1_1.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
%
% Genova,   Dec 2018
% Modified: Sept 2020
% Modified: Dec. 2021
%
%% ------------Initialization----------------
                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% nonlinear optimization: bounds %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% joints limits of independent joints. The others joints are 0 or symmetric
jointPositionLimits = [-20,  70;  ...                                                      % torso pitch
                       -90,  10;  0,   160; -35,  80;  15,  105; ...                       % arms 
                       -35,  80; -15,  90;  -70,  70; -100, 0;  -30,  30; -20,  20] * 0.5; % legs

Config.Optimization.lowerBoundJointPos = jointPositionLimits(:,1)*pi/180;
Config.Optimization.upperBoundJointPos = jointPositionLimits(:,2)*pi/180;

% jet thursts limits 
Config.Optimization.lowerBoundJets     = [0; 0; 0; 0];
Config.Optimization.upperBoundJets     = [160; 160; 220; 220];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% nonlinear optimization: thresholds %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Config.Optimization.tolerance_feet     = [0.01; 1*pi/180; 1*pi/180]; %[m; rad; rad]
Config.Optimization.tolerance_com      = [0.07; 0.05]; %[m; m]
Config.Optimization.tolerance_momentum = [0.5*ones(3,1); 0.5*ones(3,1)]; %[N; Nm]

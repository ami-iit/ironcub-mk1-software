% INITJOINTPOSOPTIMIZATION_MK1 initialization for the joint position optimization.
%                              This file is for the robot iRonCub-Mk1.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018; Modified: Sept 2020

%% ------------Initialization----------------
                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% nonlinear optimization: weights %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weights on postural task (keep initial position/thrust)
WeightsBasePos  = 0.1.*eye(3);
WeightsBaseRot  = 0.1.*eye(3);
WeightsJointPos = 50.*eye(length(Config.initJointPosOpt.jointPos_init));
WeightsTurbines = 0.1.*eye(Config.TurbinesData.njets);

Config.Optimization.WeightsMatrixPostural = blkdiag(WeightsBasePos,WeightsBaseRot,WeightsJointPos,WeightsTurbines);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% nonlinear optimization: bounds %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% joints limits. NOTE: the joints order is hard-coded.
%
% TODO: avoid hard-coding the order of the joints
jointPositionLimits = [-20,  70; -30,  30;  -50,  50; ...                                %torso
                       -90,  10;  0,   160; -35,  80;  15,  105; ...                     %larm
                       -90,  10;  0,   160; -35,  80;  15,  105; ...                     %rarm
                       -35,  80; -15,  90;  -70,  70; -100, 0;  -30,  30; -20,  20; ...  %rleg  
                       -35,  80; -15,  90;  -70,  70; -100, 0;  -30,  30; -20,  20];     %lleg

lowerBoundJointPos  = jointPositionLimits(:,1)*pi/180;
upperBoundJointPos  = jointPositionLimits(:,2)*pi/180;

% limits for the base position and rotation
basePosDelta        =  0.1;       %[m]
baseRotDelta        =  50*pi/180; %[rad]

% turbines bounds
turbineLimits       = [220, 220, 100, 100]; 
upperBoundTurbines  = transpose(turbineLimits);
lowerBoundTurbines  = zeros(Config.TurbinesData.njets,1);

upperBoundBasePos   = Config.initJointPosOpt.w_H_b_init(1:3,4) + basePosDelta.*ones(3,1); %[m]
lowerBoundBasePos   = Config.initJointPosOpt.w_H_b_init(1:3,4) - basePosDelta.*ones(3,1); %[m]
upperBoundBaseRot   = wbc.rollPitchYawFromRotation(Config.initJointPosOpt.w_H_b_init(1:3,1:3)) + baseRotDelta.*ones(3,1); %[rad]
lowerBoundBaseRot   = wbc.rollPitchYawFromRotation(Config.initJointPosOpt.w_H_b_init(1:3,1:3)) - baseRotDelta.*ones(3,1); %[rad]

Config.Optimization.upperBound = [upperBoundBasePos;upperBoundBaseRot;upperBoundJointPos;upperBoundTurbines];
Config.Optimization.lowerBound = [lowerBoundBasePos;lowerBoundBaseRot;lowerBoundJointPos;lowerBoundTurbines];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% arms and legs symmetry constraint %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% jets dofs
njets = Config.TurbinesData.njets;

Config.Optimization.SymmMatrix = [zeros(1,6) 0 0 0  1  0  0  0 -1  0  0  0  zeros(1,12) zeros(1,njets);
                                  zeros(1,6) 0 0 0  0  1  0  0  0 -1  0  0  zeros(1,12) zeros(1,njets);
                                  zeros(1,6) 0 0 0  0  0  1  0  0  0 -1  0  zeros(1,12) zeros(1,njets);
                                  zeros(1,6) 0 0 0  0  0  0  1  0  0  0 -1  zeros(1,12) zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  1  0  0  0  0  0 -1  0  0  0  0  0 zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  0  1  0  0  0  0  0 -1  0  0  0  0 zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  0  0  1  0  0  0  0  0 -1  0  0  0 zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  0  0  0  1  0  0  0  0  0 -1  0  0 zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  0  0  0  0  1  0  0  0  0  0 -1  0 zeros(1,njets);
                                  zeros(1,6) 0 0 0  zeros(1,8)  0  0  0  0  0  1  0  0  0  0  0 -1 zeros(1,njets)];

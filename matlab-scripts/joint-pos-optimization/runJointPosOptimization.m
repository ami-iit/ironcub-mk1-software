% RUNJOINTPOSOPTIMIZATION runs the joints position optimization algorithm.
%                         
% The objective is to find a joints configuration that can be used as 
% reference position for the take-off in flight-0 controller. 
%
% The optimal configuration is calculated by solving the following 
% minimization problem:
%
%   u = (w_H_b, T, s) variables to minimize, listed as:
%
%   w_H_b = base position and orientation
%   T     = thrust intensities
%   s     = joint positions
%
% The problem to be sloved is
%
%   min_u (u-u^d)^T*K_u*(u-u^d)
%        s.t  
%            lb < u < ub input boundaries
%            g(u)    = 0 feet fixed constraints
%            S*u     = 0 symmetry constraints
%            LDot(u) = 0 momentum rate of change = 0
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018, 
%   Modified: Sept 2020
%   Modified: Dec 2021

%% ------------Initialization----------------
clear variables
close all
clc

% add path to local functions
addpath('./src')

% run the script for initializing the robot
run('./init/loadRobot_MK1_1.m'); %run('./init/loadRobot_MK1.m');

% run the script for setting up the joint position optimization
run('./init/initJointPosOptimization_MK1_1.m'); %run('./init/initJointPosOptimization_MK1.m');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%% NONLINEAR OPTIMIZATION %%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

% get initial conditions and references
[uInit, uDes] = computeInitialConditionsAndReferences(Config.initJointPosOpt.w_H_b_init, Config.initJointPosOpt.jointPos_init, ...
                                                      Config.initJointPosOpt.jetIntensities_init);

% compute the nonlinear constraints
%
% constraints list:
%
% 1. feet fixed constraints
% 2. momentum derivative  = 0
%
nonLinearConstraints = @(u) computeNonLinearConstraints(u, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData, ...
                                                        Config.initJointPosOpt.w_H_lFootInit, Config.initJointPosOpt.w_H_rFootInit, ...
                                                        Config.initJointPosOpt.useFixedLinkConstraints, ...
                                                        Config.initJointPosOpt.fixOnlyHeightPitchRoll);

% compute the cost function for nonlinear optimization
%
% tasks list:
%
% 1. postural
%                    
costFunction = @(u) transpose((u-uDes)) * Config.Optimization.WeightsMatrixPostural * (u-uDes);

% set options of the nonlinear optimization
options = optimoptions('fmincon','MaxFunEvals',70000,'MaxIter',70000);
        
% nonlinear optimization
disp('[runJointPosOptimization]: running optimization...')
[uStar, fval, exitflag, output] = fmincon(costFunction, uInit, [], [], Config.Optimization.SymmMatrix, zeros(size(Config.Optimization.SymmMatrix,1),1), ...
                                          Config.Optimization.lowerBound, Config.Optimization.upperBound, nonLinearConstraints, options);   

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%% DISPLAY RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

% check 1: compare the momentum derivatives (initial, final)
initialMomentumDerivative = computeMomentumDerivative(uInit, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData);
finalMomentumDerivative   = computeMomentumDerivative(uStar, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData);

disp('Momentum derivative: [initial, final]')
disp(num2str([initialMomentumDerivative, finalMomentumDerivative]))

% check 2: display the initial and optimized joints position
disp(' ')
disp('Joints position: [initial, optimized]')
disp(num2str([uDes(7:6+length(Config.initJointPosOpt.jointPos_init)), uStar(7:6+length(Config.initJointPosOpt.jointPos_init))]*180/pi))

% check 3: display the initial and optimized thrusts intensities
disp(' ')
disp('Thrust intensities: [initial, optimized]')
disp(num2str([uDes(end-length(Config.initJointPosOpt.jetIntensities_init)+1:end), uStar(end-length(Config.initJointPosOpt.jetIntensities_init)+1:end)]))

% optimal pose visualization
disp('[runJointPosOptimization]: visualize the robot pose...')
visualizeRobot(KinDynModel, uStar);

rmpath('./src')
disp('[runJointPosOptimization]: optimization exited correctly.')

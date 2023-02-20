% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Jan 2021
% Modified: Dec. 2021

% The script iterates randomly on the joint positions until it finds one
% that satisfy a user-defined fitness function. The criteria to satisfy the
% fitness are:
%
% 1) Respect the CoM and feet constraints.
% 2) A-posteriori check on the momentum derivative value.

%% ------------Initialization----------------
clear variables
close all
clc

% add path to local functions
addpath('./src')

% run the script for robot initialization and for setting up the
% joints positions and thrusts optimization parameters
run('./init/loadRobot_MK1_1.m');
run('./init/initJointPosOptimization_MK1_1.m');

% test basis of the GA
populationSize = 1;
maxNIter       = 1000;

% select critaria to consider the posture valid
Config.POSTURE_VALID_IF_FEET_RESPECTED    = true;
Config.POSTURE_VALID_IF_COM_RESPECTED     = true;
Config.POSTURE_VALID_IF_LIN_MOM_RESPECTED = false;
Config.POSTURE_VALID_IF_ANG_MOM_RESPECTED = false;

% set options of the nonlinear optimization
Config.solverOptions = optimoptions('fmincon','MaxFunEvals',70000,'MaxIter',70000,'Display','off');

tic;

[jointPositions, constraintsSatisfied] = generateValidJointsPositions(KinDynModel, populationSize, maxNIter, Config);

time = toc;

% data processing
disp("Joint positions")
disp(num2str(jointPositions*180/pi))
disp(" ")

LDot = computeMomentumDerivative(KinDynModel, Config);

disp("Momentum derivative")
disp(num2str(LDot))

% check how many constraints were satified at each iteration
figure
hold on
grid on
plot(sum(constraintsSatisfied),'xb','markersize',10)

% visualization
visualizeRobot(KinDynModel, jointPositions, Config);

% remove path to local functions
rmpath('./src')

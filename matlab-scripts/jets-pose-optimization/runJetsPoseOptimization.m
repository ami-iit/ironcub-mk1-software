% RUNJETSPOSEOPTIMIZATION runs the jets pose optimization simulation.
%
% PURPOSE: the idea is to choose the best jets configuration among several 
%          available configurations. The criteria for choosing the jets 
%          configuration will be to choose the one that guarantees the 
%          controllability of the robot momentum through the system's control
%          inputs, i.e. the thrusts rate of change and the joints velocities.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close all
clc

addpath('./src')

% run the script containing the initial conditions for the jets pose optimization demo
run('./init/initJetsPoseOptimization.m');

DEBUG         = false;
cont          = 1;
avg_condNum_P = [];

% loop on the available tests
for testNumber = Config.initJetsPoseOpt.testNumbersVector

    disp(['[runJetsPoseOptimization]: running test number ', num2str(testNumber)])
    
    % generate the turbines data structure according to the current test
    TurbinesData = switchModel(testNumber);

    % create a modified urdf model that contains only the selected turbines
    newModelName = generateUrdfModelForTesting(TurbinesData, Config.Model);
    
    % load the reduced model
    KinDynModel  = iDynTreeWrappers.loadReducedModel(Config.Model.jointList, Config.Model.baseLinkName, ...
                                                     Config.Model.modelPath, newModelName, DEBUG); 

    % move the robot joints to measure how the condition number varies
    avg_condNum_P(cont) = moveRobotJoints(KinDynModel, TurbinesData, Config.initJetsPoseOpt); %#ok<SAGROW>
    
    % delete the urdf model that has been created for the i-th test
    delete([Config.Model.modelPath,newModelName])
    
    disp(['[runJetsPoseOptimization]: removing ',newModelName])
    
    cont = cont + 1;
end

disp('[runJetsPoseOptimization]: optimization finished. Plotting results...')

% plot averge condition numbers
trials     = 1:Config.initJetsPoseOpt.tMax*100;
testNumber = {};

for k = 1:length(avg_condNum_P)
    
    figure(1)
    plot(trials, avg_condNum_P(k).*ones(length(trials),1),'Linewidth',2)
    hold on
    grid on
    xlabel('Trials')
    ylabel('Average condition Number')
    testNumber{k} = ['test ' num2str(k)]; %#ok<SAGROW>
    legend(testNumber)
end

rmpath('./src')

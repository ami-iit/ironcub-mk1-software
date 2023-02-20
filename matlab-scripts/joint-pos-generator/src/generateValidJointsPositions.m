function [jointPositions, constraintsSatisfied] = generateValidJointsPositions(KinDynModel, populationSize, maxNIter, Config)
    
    % generate all possible joint positions in between the joints limits,
    % assuming the following constraints:
    %
    % 1) torso roll and yaw are always zero;
    % 2) right arm and right leg joints must be symmetric w.r.t. left
    % 3) all other joints are in between the joints limits
    %
    % Note: the list of joints is hard-coded
    % Note: joint positions are sampled with 1 degree steps
    %
    torso_pitch_angles    = Config.Optimization.lowerBoundJointPos(1):1*pi/180:Config.Optimization.upperBoundJointPos(1);
    shoulder_pitch_angles = Config.Optimization.lowerBoundJointPos(2):1*pi/180:Config.Optimization.upperBoundJointPos(2);
    shoulder_roll_angles  = Config.Optimization.lowerBoundJointPos(3):1*pi/180:Config.Optimization.upperBoundJointPos(3);
    shoulder_yaw_angles   = Config.Optimization.lowerBoundJointPos(4):1*pi/180:Config.Optimization.upperBoundJointPos(4);
    elbow_angles          = Config.Optimization.lowerBoundJointPos(5):1*pi/180:Config.Optimization.upperBoundJointPos(5);
    hip_pitch_angles      = Config.Optimization.lowerBoundJointPos(6):1*pi/180:Config.Optimization.upperBoundJointPos(6);
    hip_roll_angles       = Config.Optimization.lowerBoundJointPos(7):1*pi/180:Config.Optimization.upperBoundJointPos(7);
    hip_yaw_angles        = Config.Optimization.lowerBoundJointPos(8):1*pi/180:Config.Optimization.upperBoundJointPos(8);
    knee_angles           = Config.Optimization.lowerBoundJointPos(9):1*pi/180:Config.Optimization.upperBoundJointPos(9);
    ankle_pitch_angles    = Config.Optimization.lowerBoundJointPos(10):1*pi/180:Config.Optimization.upperBoundJointPos(10);
    ankle_roll_angles     = Config.Optimization.lowerBoundJointPos(11):1*pi/180:Config.Optimization.upperBoundJointPos(11);
    
    % generate random positions, and verify a-posteriori that they do not 
    % violate the constraints
    populationCounter     = 0;
    nIter                 = 1;
    jointPositions        = zeros(Config.Model.ndof,  populationSize);
    constraintsSatisfied  = [];
   
    disp(nIter)
    
    while populationCounter < populationSize
 
        % random indeces generation
        rng('shuffle') 
        random_indeces    = [floor(rand(1)*length(torso_pitch_angles))+1;
                             floor(rand(1)*length(shoulder_pitch_angles))+1;
                             floor(rand(1)*length(shoulder_roll_angles))+1;
                             floor(rand(1)*length(shoulder_yaw_angles))+1;
                             floor(rand(1)*length(elbow_angles))+1;
                             floor(rand(1)*length(hip_pitch_angles))+1;
                             floor(rand(1)*length(hip_roll_angles))+1;
                             floor(rand(1)*length(hip_yaw_angles))+1;
                             floor(rand(1)*length(knee_angles))+1;
                             floor(rand(1)*length(ankle_pitch_angles))+1;
                             floor(rand(1)*length(ankle_roll_angles))+1];
                          
        % select random joint positions
        jointPos_rnd      = [torso_pitch_angles(random_indeces(1)); 0; 0;
                             shoulder_pitch_angles(random_indeces(2)); shoulder_roll_angles(random_indeces(3)); shoulder_yaw_angles(random_indeces(4)); elbow_angles(random_indeces(5));
                             shoulder_pitch_angles(random_indeces(2)); shoulder_roll_angles(random_indeces(3)); shoulder_yaw_angles(random_indeces(4)); elbow_angles(random_indeces(5));
                             hip_pitch_angles(random_indeces(6)); hip_roll_angles(random_indeces(7)); hip_yaw_angles(random_indeces(8)); knee_angles(random_indeces(9)); ankle_pitch_angles(random_indeces(10)); ankle_roll_angles(random_indeces(11));
                             hip_pitch_angles(random_indeces(6)); hip_roll_angles(random_indeces(7)); hip_yaw_angles(random_indeces(8)); knee_angles(random_indeces(9)); ankle_pitch_angles(random_indeces(10)); ankle_roll_angles(random_indeces(11))];                      
                         
        % update robot state with the new generated joints position            
        updateRobotState(jointPos_rnd, KinDynModel, Config.Model.gravityAcc, Config.Model.ndof);
        
        % verify constraints on the feet and on the CoM
        constraintsSatisfied(:,nIter) = computeFitness(KinDynModel, Config); %#ok<AGROW>
        postureIsValid = verifyFitness(constraintsSatisfied(:,nIter), Config);
        
        if postureIsValid || nIter > maxNIter
              
            if nIter > maxNIter
                
                disp("Max number of iterations reached.")
            else
                disp("Good population member found.")
            end
            
            populationCounter                   = populationCounter + 1;
            jointPositions(:,populationCounter) = jointPos_rnd;
        end
          
        nIter = nIter + 1;
        
        clc
        disp(nIter)
    end
end

function avg_condNum_P = moveRobotJoints(KinDynModel,TurbinesData,initJetsPoseOpt)

    % MOVEROBOTJOINTS moves the robot joints according to a pseudo-random
    %                 pattern. Also the thrusts magnitude varies randomly
    %                 between max and min thrust. 
    %
    % FORMAT:  avg_condNum_P = moveRobotJoints(KinDynModel,TurbinesData,initJetsPoseOpt)
    %
    % INPUTS:  - TurbinesData: structure containing the turbines data;
    %
    %                          REQUIRED FIELDS:
    %
    %                          - turbineList: [cell array of strings];
    %                          - turbineLimits: [vector of double];
    %                          - turbineAxis: [vector of int];
    %
    %          - initJetsPoseOpt: simulation-specific configuration parameters;
    %                  
    %                   REQUIRED FIELDS: 
    %
    %                   - jointPos_init: [vector of double];
    %                   - jointVel_init: [vector of double];
    %                   - gravityAcc: [vector of double];
    %                   - tMax: [double];
    %                   - jointPosLimits: [double];
    %                   - minThrust: [double];
    %    
    % OUTPUTS: - avg_condNum_P : the average condition number during the test.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Nov 2018

    %% ------------Initialization----------------
    
    % set the initial robot configuration
    iDynTreeWrappers.setRobotState(KinDynModel,initJetsPoseOpt.jointPos_init,initJetsPoseOpt.jointVel_init,initJetsPoseOpt.gravityAcc)
 
    % get the number of DoFs
    ndof      = iDynTreeWrappers.getNrOfDegreesOfFreedom(KinDynModel);

    % initialize the robot joints movements
    exitLoop  = false;
    t         = 0;
    tMax      = initJetsPoseOpt.tMax;
    cont      = 0;

    % intialize the condition number
    condNum_P = 0;
    
    disp('[moveRobotJoints]: starting the optimization procedure...')
    
    while ~exitLoop
    
        t    = t + 0.01;
        cont = cont +1;
    
        % update the joints trajectories by adding/subtracting a random value.
        % The random value can be any value in the interval +/- jointPosLimits
        currentJointPos = initJetsPoseOpt.jointPosLimits(:,1) + (initJetsPoseOpt.jointPosLimits(:,2) - initJetsPoseOpt.jointPosLimits(:,1)).*rand(ndof,1); % [rad]
    
        % set the new joints position
        iDynTreeWrappers.setRobotState(KinDynModel,currentJointPos,initJetsPoseOpt.jointVel_init,initJetsPoseOpt.gravityAcc);
        
        % compute the condition number
    
        % random adjustment to the thrust magnitude. The thrust magnitude can
        % vary randomly from 0 to maxThrust
        randomThrustDelta = rand(1,length(TurbinesData.turbineLimits));
    
        % minimum value of the thrust force (if very close to zero, the matrix
        % may become singular)
        minThrust     = initJetsPoseOpt.minThrust; % [N]
    
        % turbine data
        turbineList   = TurbinesData.turbineList;
        turbineAxis   = TurbinesData.turbineAxis;
        turbineLimits = minThrust + (TurbinesData.turbineLimits-minThrust).*randomThrustDelta;
    
        % projector matrix
        P = computeProjectorMatrix(KinDynModel,turbineList,turbineAxis,turbineLimits);
   
        % condition number
        [~,v,~]         = svd(P);
        singularValues  = diag(v);
        minSingValue    = min(singularValues);
        maxSingValue    = max(singularValues);
        condNum_P(cont) = minSingValue/maxSingValue;  %#ok<AGROW>
       
        if t > tMax
        
            exitLoop = true;
        end 
    end

    % compute the average of the condition number of P over all the movements
    avg_condNum_P = sum(condNum_P)/length(condNum_P);
    
    disp('[moveRobotJoints]: optimization finished')
end

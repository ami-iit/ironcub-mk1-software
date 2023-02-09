function [c,ceq] = computeNonLinearConstraints(u, KinDynModel, gravAcc, TurbinesData, w_H_lFootInit, w_H_rFootInit, useFixedLinkConstraints, fixOnlyHeightPitchRoll)

    % COMPUTENONLINEARCONSTRAINTS computes the nonlinear constraints for the
    %                             joints position optimization.
    %
    % FORMAT:  [c,ceq] = computeNonLinearConstraints(u,KinDynModel,gravAcc,TurbinesData,...
    %                                                w_H_lFootInit,w_H_rFootInit,useFixedLinkConstraints,fixOnlyHeightPitchRoll)
    %
    % INPUTS:  - u: [6+ndof+njets x 1] optimization variable;
    %          - KinDynModel: a structure containing the loaded model and additional info;
    %          - gravAcc:[3 x 1] vector of the gravity acceleration in the inertial frame;
    %          - TurbinesData: [struct] turbines specifications:
    %
    %                          REQUIRED FIELDS:
    % 
    %                          - njets: [int];
    %
    %          - w_H_lFootInit: [4 x 4] from lFoot to world initial
    %                           transformation matrix;
    %          - w_H_rFootInit: [4 x 4] from rFoot to world initial
    %                           transformation matrix;
    %          - useFixedLinkConstraints: if true, the feet are assumed to
    %                                     be fixed and the constraint on feet
    %                                     is added to the list;
    %          - fixOnlyHeightPitchRoll: if true, the feet x,y,yaw are not
    %                                    constrained and therefore free to move.
    %    
    % OUTPUTS: - c: equation representing the nonlinear inequality
    %               constraints. Format: c(u) < = 0;
    %          - ceq: equation representing the nonlinear equality
    %                 constraints. Format: ceq(u) = 0.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018; 
    %
    % Modified Sept. 2020
    % Modified Dec. 2021

    %% ------------Initialization----------------
    
    % nonlinear equality constraints
    ceq   = [];
    
    % turbines and joints data
    njets = TurbinesData.njets;
    ndof  = iDynTreeWrappers.getNrOfDegreesOfFreedom(KinDynModel);
    
    % state demux and convert Euler angles in rotation matrix
    [basePos, baseRot, jointPos, ~] = wbc.vectorDemux(u, [3;3;ndof;njets]);
    
    w_R_b = wbc.rotationFromRollPitchYaw(baseRot);
    w_H_b = [w_R_b, basePos;
             0   0   0  1];
    
    % set the current model state
    iDynTreeWrappers.setRobotState(KinDynModel, w_H_b, jointPos, zeros(6,1), zeros(ndof,1), gravAcc);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% FixedLinks constraints %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % it is assumed that the two fixed links are the feet
    %
    % TODO: generalize to any fixed link
    %
    % initial feet orientation
    rollPitchYaw_LfootInit = wbc.rollPitchYawFromRotation(w_H_lFootInit(1:3,1:3));
    rollPitchYaw_RfootInit = wbc.rollPitchYawFromRotation(w_H_rFootInit(1:3,1:3));
    
    % current feet pose
    w_H_lFoot              = iDynTreeWrappers.getWorldTransform(KinDynModel,'l_sole');
    w_H_rFoot              = iDynTreeWrappers.getWorldTransform(KinDynModel,'r_sole');
    
    % convert to RPY
    rollPitchYaw_Lfoot     = wbc.rollPitchYawFromRotation(w_H_lFoot(1:3,1:3));
    rollPitchYaw_Rfoot     = wbc.rollPitchYawFromRotation(w_H_rFoot(1:3,1:3));
    
    constraintsLfoot       = [(w_H_lFoot(1:3,4)-w_H_lFootInit(1:3,4));(rollPitchYaw_Lfoot-rollPitchYaw_LfootInit)];
    constraintsRfoot       = [(w_H_rFoot(1:3,4)-w_H_rFootInit(1:3,4));(rollPitchYaw_Rfoot-rollPitchYaw_RfootInit)];
    
    % WARNING: we compute the nonlinear constraints as INEQUALITY constraints. 
    % They are actually equality constraints with a small tolerance
    tolerance = [0.001*ones(12,1); 0.02*ones(6,1)];
    
    if useFixedLinkConstraints
        
        c = abs([constraintsLfoot; constraintsRfoot; computeMomentumDerivative(u, KinDynModel, gravAcc, TurbinesData)])-tolerance;
        
        if fixOnlyHeightPitchRoll
           
            c = c([1,2,4,5,7,8,10,11,13:end]);
        end   
    else
        c = abs(computeMomentumDerivative(u, KinDynModel, gravAcc, TurbinesData))-tolerance(13:end);
    end
end

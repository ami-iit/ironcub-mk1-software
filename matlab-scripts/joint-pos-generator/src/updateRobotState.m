function [] = updateRobotState(jointPos, KinDynModel, gravAcc, ndof)

    % set the current joint positions
    iDynTreeWrappers.setRobotState(KinDynModel, eye(4), jointPos, zeros(6,1), zeros(ndof,1), gravAcc);
    
    % assumption: left foot is fixed to the ground and the inertial frame 
    % is the left foot frame. Then, get the w_H_b homogeneous matrix
    w_H_b_lFoot_fixed = iDynTreeWrappers.getRelativeTransform(KinDynModel,'l_sole','root_link');
    
    % set the robot pose (with the correct transformation matrix)
    iDynTreeWrappers.setRobotState(KinDynModel, w_H_b_lFoot_fixed, jointPos, zeros(6,1), zeros(ndof,1), gravAcc);
end

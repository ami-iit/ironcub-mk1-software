function [constr_feet, constr_com] = computeFeetAndCoMConstraints(KinDynModel)
    
    % Feet must be co-planar:
    %
    % 1) left foot is fixed, and the left foot frame is the inertial frame;
    % 2) right foot height must be zero;
    % 3) right foot roll and pitch must be zero.
    %
    w_H_RFoot   = iDynTreeWrappers.getWorldTransform(KinDynModel,'r_sole');
    rpy_RFoot   = wbc.rollPitchYawFromRotation(w_H_RFoot(1:3,1:3));    
    constr_feet = abs([w_H_RFoot(3,4); rpy_RFoot(1:2)]);

    % CoM must be in the support polygon:
    %
    % 1) left foot is fixed, and the left foot frame is the inertial frame;
    % 2) CoM should be in the support polygon, but more specifically:
    %
    %    - close to the point in the middle between the left and right foot
    %    - with a small tolerance w.r.t. the mid point.
    %                
    posCoM      = iDynTreeWrappers.getCenterOfMassPosition(KinDynModel);                   
    constr_com  = abs(posCoM(1:2) - w_H_RFoot(1:2,4)*0.5);
end

function [H_angMomentum, g_angMomentum, ATilde_angular, BTilde_angular, deltaTilde_angular, verifyAngMomAndInertia, w_L_angMom_des] = ...
            flyingAttitudeControl(w_R_b, w_I_c, w_baseTwist, CMM, rot_vel_acc_jerk_base_des, Ac, Aj, Lambda_cb, Lambda_cs, Lambda_jb, ...
                                  Lambda_js, L, LDot_estimated, feetContactIsActive, c0, c1)
             
    % persistent variables definition
    persistent b_I_c_0;

    % ACHIEVE A DESIRED SYSTEM'S ANGULAR MOMENTUM:
    %
    % Consider a frame G[w], that is a frame with the origin at the robot's
    % CoM and the orientation of the inertial frame. Then, the angular momentum
    % of the robot w.r.t. G[w] can be expressed as follows:
    %
    %   G[w]_L_ang = G[w]_I_c * w_omega_G (1)
    %
    % where G[w]_I_c  = total robot's inertia expressed in the frame G[w]; 
    %       w_omega_G = average (or locked) angular velocity expressed in w.
    %
    % First of all, recall that the average angular velocity can be rewritten 
    % as a function of the base angular velocity and the joints velocity:
    %
    %   w_omega_G = w_omega_b + Js_angMom * sDot (2)
    %
    % Substituting (2) into (1) gives:
    %
    %   G[w]_L_ang = G[w]_I_c * (w_omega_b + Js_angMom * sDot)
    %              = G[w]_I_c * w_omega_b + CMMs_angMom * sDot (3)
    %
    % where CMMs_angMom is a partition of the centroidal momentum matrix.
    %
    % Note that G[w]_I_c = G[w]_I_c(q), i.e. it depends of the full system
    % configuration. For control purposes, we chose sDot (that we
    % assume to be a control input) such that Eq. (3) becomes:
    %
    %    G[w]_L_ang = G[w]_I_c0 * w_omega_b (4)
    %
    % with G[w]_I_c0 = G[w]_I_c(t = 0). Having a constant robot total inertia 
    % is a requirement for the attitude control. However, this is in general
    % a strong limitation! For example, imagine the robot rotates 90 [deg]
    % around the y-axis (switch from flying vertically to flying horizontally):
    % then, the total inertia W.R.T. THE INERTIAL FRAME is far from being costant, 
    % and the matrix CMMs_angMom goes singular, i.e at a certain point one
    % can't control G[w]_L_ang using sDot anymore. 
    %
    % However, note that if someone expresses the total inertia in body (b)
    % coordinates, i.e. G[b]_I_c, then it only depends on the joint configuration,
    % i.e.  G[b]_I = G[b]_I_c(s). One can assume that while the robot is flying
    % the joint configuration always remains close to the initial position, and
    % therefore it may reasonable to try to achieve Eq. (4) when expressed in
    % body coordinates. Therefore we express Eq. (3) in body coordinates:
    %
    %    G[b]_L_ang = G[b]_I_c * b_omega_b + b_JH_angMom * sDot (5)
    %
    % where: G[b]_I_c    = b_R_w * G[w]_I_c * w_R_b
    %        b_omega_b   = b_R_w * w_omega_b  
    %        b_JH_angMom = b_R_w * CMMs_angMom
    %              
    % Finally, Eq.(4) is applied on (5) instead of (3). 

    % Auxiliary variables for computing Eq. (5)
    ndof        = size(Lambda_js,2);
    b_R_w       = transpose(w_R_b);
    w_omega_b   = w_baseTwist(4:6);

    % Compute the terms of Eq. (5)
    b_I_c       = b_R_w * w_I_c * w_R_b;
    b_omega_b   = b_R_w * w_omega_b;
    b_JH_angMom = b_R_w * CMM(4:6,7:ndof+6);
             
    if isempty(b_I_c_0)
       
        b_I_c_0 = b_I_c;
    end
    
    % Define the desired angular momentum in body coordinates
    b_L_angMom_reference = b_I_c_0 * b_omega_b;
        
    % The joint velocities which satisfies (4) are obtained using a QP
    % solver. This allows to include joint velocities and joint positions
    % limits in order to ensure that the control input is not in conflict
    % with the constraint. 
    %
    % WARNING: if the QP fails to find a solution, there is no way to achieve 
    % the desired angular momentum and therefore the attitude controller will 
    % FAIL to control the robot's attitude!
    %
    % TODO: it is most likely not possible to prove that it is always
    % possible to satisfy (4), as it is probably not true. Depending on the
    % kind of task the robot has to do, the joints limits and other
    % variables it may be possible that the attitude controller's main
    % assumption is not satisfied. What it may be easy to do is to
    % constantly check if the assumption is satisfied and, if not, take
    % some sort of safety measurements.
    H_angMomentum   = blkdiag(zeros(4), zeros(12), transpose(b_JH_angMom) * b_JH_angMom); 
    g_angMomentum   = [zeros(4,1); zeros(12,1); transpose(b_JH_angMom) * (b_I_c * b_omega_b - b_L_angMom_reference)];

    % ATTITUDE CONTROL:
    %
    % Attitude control: Now that the joint velocities have been chosen in order
    % to ensure that  G[b]_L_ang = G[b]_I_c0 * b_omega_b, let us compute the
    % second derivative of the angular momentum in body coordinates, that is:
    %
    %     G[b]_LDDot_ang = G[b]_I_c0 * b_omegaDDot_b (6)
    %
    % Eq. (6) holds provided that the constraint applied on Eq. (5) remains
    % always feasible. At this point, we assume one can impose:
    %
    %     G[b]_LDDot_ang = G[b]_LDDot_ang_star
    %
    % where G[b]_LDDot_ang_star is the control input for an attitude control
    % that guarantees the convergence of LDot_ang, L_ang and w_R_b towards 
    % desired values. For more details on this attitude control and for the 
    % Lyapunov analysis check the IEEE-HUMANOIDS 2018 paper.

    % base rotation references (body coordinates)
    w_R_b_des           = rot_vel_acc_jerk_base_des(1:3,1:3);
    b_omega_b_des       = rot_vel_acc_jerk_base_des(1:3,4);
    b_omegaDot_b_des    = rot_vel_acc_jerk_base_des(1:3,5);
    b_omegaDDot_b_des   = rot_vel_acc_jerk_base_des(1:3,6);

    % angular momentum references (body coordinates)
    b_L_angMom_des      = b_I_c_0 * b_omega_b_des;
    b_LDot_angMom_des   = b_I_c_0 * b_omegaDot_b_des;
    b_LDDot_angMom_des  = b_I_c_0 * b_omegaDDot_b_des; 
 
    % angular momentum and derivative of the angular momentum in body
    % coordinates. Note that what follows implies that the joint velocities
    % are chosen such that (4) holds. If (4) holds, then these quantitities 
    % do not depend on the joint velocities
    b_L_angMom          = b_I_c_0 * b_omega_b;
    b_LDot_angMom       = b_R_w * LDot_estimated(4:6) - wbc.skew(b_omega_b) * b_L_angMom;

    % angular momentum error and angular momentum derivative error
    b_L_angMom_tilde    = b_L_angMom    - b_L_angMom_des; 
    b_LDot_angMom_tilde = b_LDot_angMom - b_LDot_angMom_des;

    % base rotation error in SO(3) and its derivative (body coordinates)
    b_skv               = wbc.skewVee(transpose(w_R_b_des) * w_R_b);
    b_skvDot            = wbc.skewVee(((transpose(w_R_b_des) * w_R_b) * wbc.skew(b_omega_b) ...
                                      - wbc.skew(b_omega_b_des) * (transpose(w_R_b_des) * w_R_b)));
 
    % inverse of the total robot inertia in body coordinates
    b_I_c_0_inv         = eye(3) / b_I_c_0;

    % attitude control in BODY coordinates
    errorAngMom         = c1 * b_I_c_0_inv * b_L_angMom_tilde;
    errorBaseRot        = c0 * b_I_c_0_inv * b_skv;
    errorAngMomDot      = (eye(3) + c0 * b_I_c_0_inv) * b_LDot_angMom_tilde;
    b_LDDot_angMom_star = b_LDDot_angMom_des - b_skvDot - errorAngMomDot - errorBaseRot - errorAngMom;
    
    % ACHIEVE THE DESIRED SYSTEM'S ANGULAR MOMENTUM ACCELERATION:
    %
    % Note that the formula relating the ACTUAL control inputs of the
    % system (joint velocities and thrust rate of change and contact forces
    % derivative) with the angular momentum acceleration is expecting the
    % angular momentum acceleration to be in WORLD coordinates, not in BODY
    % coordinates. However, we can transform the angular momentum in world
    % coordinates into the angular momentum in body coordinates:
    %
    %   G[w]_LDDot_angMom = w_R_b * (G[b]_LDDot_angMom + skew(b_omega_b)^2 * G[b]_L_angMom +
    %                                2 * skew(b_omega_b) * G[b]_LDot_angMom + skew(b_omegaDot_b) * G[b]_L_angMom)
    %
    %                     = w_R_b * G[b]_LDDot_angMom + sigma  (7)
    %
    % with sigma = w_R_b * (skew(b_omega_b)^2 * G[b]_L_angMom + 2 * skew(b_omega_b) * G[b]_LDot_angMom + 
    %                       skew(b_omegaDot_b) * G[b]_L_angMom).
    %
    % Note that if (4) holds, then Eq. (7) does not depend on the joint
    % velocities, thrust forces rate of change or joint torques. Now we are
    % left with achieving G[b]_LDDot_angMom_star. Recall the following relations:
    %
    % WHILE FLYING:
    %
    %   w_LDDot_angMom = Aj_angMom * jetsIntensitiesDot + Lambda_js_angMom * sDot + Lambda_jb_angMom * nu_base (8a)
    %
    % WHILE BALANCING:
    %
    %   w_LDDot_angMom = Aj_angMom * jetsIntensitiesDot + Lambda_js_angMom * sDot + Lambda_jb_angMom * nu_base + ...
    %                    Ac_angMom * contactForcesDot + Lambda_cs_angMom * sDot + Lambda_cb_angMom * nu_base   (8b)   
    %
    % therefore it depends on the control inputs sDot, contactForcesDot,
    % and jetIntensitiesDot. It can be feedback-linearized and added as a
    % task to the QP solver. In particular, we rewrite the task as:
    %
    %   w_LDDot_angMom = ATilde_angular * [jetsIntensitiesDot; contactForcesDot] + BTilde_angular * sDot + deltaTilde_angular (9)
    %
    % By substituting (7) we have:
    %
    %   b_LDDot_angMom = b_R_w * (ATilde_angular * [jetsIntensitiesDot; contactForcesDot] + BTilde_angular * sDot + deltaTilde_angular - sigma) (10)
    %
    % Therefore in what follows we have to compute the terms of Eqs. (7-10).
    
    % angular accelerations in body coordinates and bias terms
    b_omegaDot_b           = b_I_c_0_inv * b_LDot_angMom;
    sigma                  = w_R_b * (wbc.skew(b_omega_b) * wbc.skew(b_omega_b) * b_L_angMom + 2 * wbc.skew(b_omega_b) * b_LDot_angMom + ...
                                      wbc.skew(b_omegaDot_b) * b_L_angMom);
                     
    % now, compute the terms of Eq. (10). Note that we included b_R_w in
    % the definition of ATilde_angular, etc, ... and also note that
    % deltaTilde_angular now contains sigma
    ATilde_angular         = b_R_w * [Aj(4:6,:), Ac(4:6,:) .* feetContactIsActive];
    BTilde_angular         = b_R_w * (Lambda_js(4:6,:) + Lambda_cs(4:6,:) .* feetContactIsActive);
    deltaTilde_angular     = b_R_w * ((Lambda_jb(4:6,:) + Lambda_cb(4:6,:) .* feetContactIsActive) * w_baseTwist - sigma) - b_LDDot_angMom_star;     
       
    % debug: verify that the constraint on the angular momentum in body coordinates
    % is respected (i.e. b_L_angMom = b_I_c0 * b_omega_b and b_I_c = b_I_c0)
    b_I_c_norm             = [norm(b_I_c), norm(b_I_c_0)];
    b_L_angMom             = b_R_w * L(4:6); 
    b_L_angMom_expected    = b_I_c_0 * b_omega_b;
    verifyAngMomAndInertia = [b_I_c_norm; b_L_angMom, b_L_angMom_expected];
    w_L_angMom_des         =  w_R_b_des * b_L_angMom_des;
end 
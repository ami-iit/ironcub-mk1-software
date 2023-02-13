function [Hessian, gradient, ConstraintMatrix_inequality, biasVectorConstraint_inequality, jointVel_err] =  ... 
             flyingTorqueControl(M, h, J_jets, J_LFoot, J_RFoot, JDot_LFoot_nu, JDot_RFoot_nu, w_H_LFoot, w_H_RFoot, matrixOfJetsAxes, ...
                                 ConstraintsMatrix_feet, biasVectorConstraint_feet, jetsIntensities, stateVel, jointVel_star, contactForces_star, ...
                                 KI_torqueControl, KP_torqueControl, feetContactIsActive, activateEqConstrTorqueControl, robotIsLanded, jointPos_err, Config)
                                                                                                         
    % FLYINGTORQUECONTROL joint torque control for balancing on two feet 
    %                     and flying. 
    %
    % Basically, the following minimization procedure is performed:
    %
    %  argmin_u 1/2 * (k1 * |sDDot - sDDot_star|^2 + k2 * |f_c - f_c_star|^2)
    %
    %          s.t.
    %                A * f_c < b
    %                J_c * nuDot + JDot_c_nu = 0 
    %
    % with u = [f_c; jointTorques].
    %
    % When flying, the control input is simplified by removing f_c (which
    % represents the contact forces at feet). The problem is solved using a
    % QP optimiziation procedure.
    %    
    persistent eps_constr_torqueControl

    if isempty(eps_constr_torqueControl)
    
        eps_constr_torqueControl = 0;
    end

    f_j            = iRonCubLib.fromJetsIntensitiesToForces(matrixOfJetsAxes, jetsIntensities);
    J_j            = [J_jets(1:3,:); J_jets(7:9,:); J_jets(13:15,:); J_jets(19:21,:)];  
    J_c            = [J_LFoot; J_RFoot];
    JDot_c_nu      = [JDot_LFoot_nu; JDot_RFoot_nu];
    ndof           = size(Config.N_DOF_MATRIX,1);
    
    % calculate the desired joint accelerations
    jointVel_err   =  stateVel(7:end) - jointVel_star;
    sDDot_star     = -(KP_torqueControl * jointVel_err + KI_torqueControl * jointPos_err); 
    
    % calculate the multiplier of u = [contactForces; jointTorques] in the 
    % joint accelerations equation and bias terms. The equation is of the
    % following form:
    %
    %  sDDot = = St_invM_bias + St_invM_B * u 
    %
    S              = [zeros(6,ndof); eye(ndof)];             
    B              = [transpose(J_c) .* feetContactIsActive, S];
    St             = transpose(S);
    invM           = eye(ndof + 6)/M;
    St_invM_B      = St * invM * B;
    St_invM_bias   = St * invM * (transpose(J_j) * f_j - h);
    
    %% QP formulation 
    
    % primary task: achieve the desired contact forces
    H_minForcesErr = blkdiag(eye(12), zeros(ndof));
    g_minForcesErr = [-contactForces_star .* feetContactIsActive; zeros(ndof,1)];
    
        
    % primary task: minimize joint accelerations error
    H_minAcc       = transpose(St_invM_B) * St_invM_B;
    g_minAcc       = transpose(St_invM_B) * (St_invM_bias - sDDot_star);
    
    % regularization task: joint torques minimization
    H_minTorques   = blkdiag(zeros(12), eye(ndof));
    g_minTorques   = zeros(12 + ndof,1);
    
    % feet equality constraints. They are added to the cost function to
    % reduce the possibility that the QP fails for infeasibility. The
    % constraints are of the form:
    %
    %  Jc_invM_B * u = - Jc_invM_bias - JDot_c_nu
    %
    Jc_invM_B      = J_c * invM * B;
    Jc_invM_bias   = J_c * invM * (transpose(J_j) * f_j - h);
    
    % equality constraints task
    H_feetConstr   = transpose(Jc_invM_B) * Jc_invM_B;
    g_feetConstr   = transpose(Jc_invM_B) * (JDot_c_nu + Jc_invM_bias);
    
    % while landing, increase progressively the weights on equality constraints
    % to have a smoother transition from flying to landing   
    if robotIsLanded
        
        weights_equalityConstraints = min((eps_constr_torqueControl + Config.deltas.delta_eps_constr_torque * activateEqConstrTorqueControl), Config.weights.eqConstraints_torqueControl);
        eps_constr_torqueControl    = eps_constr_torqueControl + Config.deltas.delta_eps_constr_torque * activateEqConstrTorqueControl;
    else
        weights_equalityConstraints = Config.weights.eqConstraints_torqueControl;
        eps_constr_torqueControl    = 0;
    end  
    
    % Hessian matrix and gradient for QP solver
    Hessian        = Config.weights.minTorques * H_minTorques + ...
                     Config.weights.minJointAcc * H_minAcc + ...
                     Config.weights.minForces * H_minForcesErr .* feetContactIsActive + ...
                     weights_equalityConstraints * H_feetConstr .* feetContactIsActive; 
                 
    gradient       = Config.weights.minTorques * g_minTorques + ...
                     Config.weights.minJointAcc * g_minAcc + ...
                     Config.weights.minForces * g_minForcesErr .* feetContactIsActive + ...
                     weights_equalityConstraints * g_feetConstr .* feetContactIsActive;

    % regularization of the Hessian matrix. Enforce symmetry and positive definiteness 
    Hessian        = (Hessian + transpose(Hessian))/2 + eye(size(Hessian,1)) * Config.reg.hessianQp; 
    
    % inequality constraints. The constraint matrix for the inequality
    % constraints is built up starting from the constraint matrix associated 
    % with each single foot. More precisely, the contact wrench associated 
    % with the left foot (resp. right foot) is subject to the following 
    % constraint:
    %
    %     constraintMatrixLeftFoot * l_sole_f_L < bVectorConstraints
    %
    % In this case, however, f_L is expressed w.r.t. the frame l_sole,
    % which is solidal to the left foot. Since the controller uses contact
    % wrenches expressed w.r.t. a frame whose orientation is that of the
    % inertial frame, we have to update the constraint matrix according to
    % the transformation w_R_l_sole, i.e.
    %
    %     constraintMatrixLeftFoot = ConstraintsMatrix * w_R_l_sole
    %
    % The same holds for the right foot.
    w_R_LFoot                       = w_H_LFoot(1:3,1:3);
    w_R_RFoot                       = w_H_RFoot(1:3,1:3);
    ConstraintMatrixLeftFoot        = ConstraintsMatrix_feet * blkdiag(transpose(w_R_LFoot), transpose(w_R_LFoot));
    ConstraintMatrixRightFoot       = ConstraintsMatrix_feet * blkdiag(transpose(w_R_RFoot), transpose(w_R_RFoot));
    ConstraintMatrix_inequality     = blkdiag(ConstraintMatrixLeftFoot, ConstraintMatrixRightFoot);
    biasVectorConstraint_inequality = [biasVectorConstraint_feet; biasVectorConstraint_feet];                            
end

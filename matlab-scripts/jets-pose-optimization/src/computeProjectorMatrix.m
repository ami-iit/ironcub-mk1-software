function P = computeProjectorMatrix(KinDynModel,turbineList,turbineAxis,turbineLimits)

    % COMPUTEPROJECTORMATRIX computes the current configuration's I/O
    %                        matrix for the jets pose optimization procedure.
    %
    % FORMAT:  P = computeProjectorMatrix(KinDynModel,turbineList,turbineAxis,turbineLimits)  
    %
    % INPUTS:  - KinDynModel: a structure containing the loaded model and additional info;
    %          - turbineList: [nTurbines x 1] list of turbines names;
    %          - turbineAxis: [nTurbines x 1] list of turbines axis;
    %          - turbineLimits: [nTurbines x 1] list of turbines limits;
    %
    % OUTPUTS: - P: [6 x nTurbines + ndof] projector matrix.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Nov 2018

    %% ------------Initialization----------------

    % CoM position and Jacobian
    w_o_CoM = iDynTreeWrappers.getCenterOfMassPosition(KinDynModel);
    J_CoM   = iDynTreeWrappers.getCenterOfMassJacobian(KinDynModel);
    J_CoM   = J_CoM(1:3,:);

    % iterate to compute matrices A and Lambda_temp
    A           = [];
    Jr          = [];
    l_jets      = [];
    r_jets      = [];
    Lambda_temp = [];

    for i = 1:length(turbineList)

        % i-th turbine pose
        w_H_j_i = iDynTreeWrappers.getWorldTransform(KinDynModel,turbineList{i});
        w_R_j_i = w_H_j_i(1:3,1:3);
        w_o_j_i = w_H_j_i(1:3,4);

        % distances between the jets positions and the CoM
        r_jets    = [r_jets, (w_o_j_i - w_o_CoM)]; %#ok<AGROW>
    
        SkewBar_i = [eye(3);    
                     wbc.skew(r_jets(:,i))]; 

        % thrust force axis
        l_jets = [l_jets, sign(turbineAxis(i))*w_R_j_i(1:3,abs(turbineAxis(i)))]; %#ok<AGROW>

        %%%% compute matrix A %%%%
        A      = [A, SkewBar_i*l_jets(:,i)]; %#ok<AGROW>
  
        % jets jacobians
        J_i    = iDynTreeWrappers.getFrameFreeFloatingJacobian(KinDynModel,turbineList{i});
        J_i_o  = J_i(1:3,:);
        J_i_w  = J_i(4:6,:);   
        J_i_r  = J_i_o - J_CoM;
    
        %%%% compute the jacobian Jr %%%%               
        Jr     = [Jr; J_i_r; J_i_w]; %#ok<AGROW>
    end

    for i = 1:length(turbineList)

       % turbine max thrust
       t_i = turbineLimits(i);

        % compute the projector of the joint velocities
       SkewTilde_i = t_i*[zeros(3)              wbc.skew(l_jets(:,i)); ...
                          wbc.skew(l_jets(:,i)) wbc.skew(r_jets(:,i))*wbc.skew(l_jets(:,i))];
                  
       Lambda_temp = [Lambda_temp, SkewTilde_i]; %#ok<AGROW>
    end

    % complete matrix lambda
    Lambda   = -Lambda_temp*Jr;

    % select the part of lambda that multiplies the joints velocities
    Lambda_s =  Lambda(:,7:end);

    %%%% Final input-output matrix (output = P * input) %%%%
    P        = [A, Lambda_s];
end

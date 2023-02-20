function LDot = computeMomentumDerivative(KinDynModel, Config)

% The momentum derivative LDot must be equal to zero.
%
% 1) left foot is fixed, and the left foot frame is the inertial frame.
% 2) jets intensities are computed to minimize LDot, but they must also
%    respect the jet limits.
%
turbineList = Config.Model.turbineList;
turbineAxis = Config.Model.turbineAxis;
mg          = Config.Model.totalMass*Config.Model.gravityAcc;
Aj          = zeros(6, length(turbineList));
posCoM      = iDynTreeWrappers.getCenterOfMassPosition(KinDynModel);

% iterate to compute matrix A
for i = 1:length(turbineList)
    
    % i-th turbine pose
    w_H_j_i   = iDynTreeWrappers.getWorldTransform(KinDynModel,turbineList{i});
    w_R_j_i   = w_H_j_i(1:3,1:3);
    w_o_j_i   = w_H_j_i(1:3,4);
    
    % distances between the jets positions and the CoM
    r_jet_i   = w_o_j_i - posCoM;
    SkewBar_i = [eye(3); wbc.skew(r_jet_i)];
    
    % thrust force axis
    l_jet_i   = sign(turbineAxis(i))*w_R_j_i(1:3,abs(turbineAxis(i)));
    
    % compute matrix A
    Aj(:,i)    = SkewBar_i*l_jet_i;
end

% jet thrusts that give zero momentum derivative, given the generated joints positions
costFunction = @(u) u'*(Aj'*Aj)*u + u'*Aj'*[mg; zeros(3,1)];

[uStar, ~, exitflag, ~] = fmincon(costFunction, zeros(4,1), [], [], [], [], Config.Optimization.lowerBoundJets, ...
                                  Config.Optimization.upperBoundJets, [], Config.solverOptions);

if exitflag < 1
    
    uStar = zeros(4,1);
end

% momentum derivative
LDot = Aj*uStar + [mg; zeros(3,1)];
end

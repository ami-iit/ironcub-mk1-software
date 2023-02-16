function [xhatDot, Pdot] = EKF_MOMENTUM_JET_FEET_CMM_FEET(x, inputs, coeff_P100, coeff_P220, P, measurement, Amatrix, GI_X_LF, GI_X_RF, gravityForce, Q, R)

% 'inputs' vector consistes of [throttle_inputs, transformed_feet_contact_forces]'

[J_A, J_C] = iRonCubLib_v1.computeJacobians_EKF_MOMENTUM_JET_FEET_CMM_FEET(x, inputs, Amatrix, GI_X_LF, GI_X_RF, coeff_P100, coeff_P220);

% evolve the system
xDot = iRonCubLib_v1.dynamics_EKF_MOMENTUM_JET_FEET_CMM_FEET(x, coeff_P100, coeff_P220, Amatrix, GI_X_LF, GI_X_RF, gravityForce,inputs);

% compute the Kalman Gain
K = P*J_C'/R;

% correct the estimation
xhatDot = xDot + K*(measurement - J_C*x);

% evolve the covariance derivative
Pdot = J_A*P + P*J_A' + Q - P*J_C'/R*J_C*P;
end

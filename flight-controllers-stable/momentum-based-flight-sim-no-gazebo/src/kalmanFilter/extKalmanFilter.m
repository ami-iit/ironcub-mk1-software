function [xhatDot, Pdot] = extKalmanFilter(x, input, coeff, P, measurement, config)
% system is the function handle describing the dynamics
% ẋ  = f(x,u) 
% system is @(x, u, coefficients)
% for now the output is x(1)
[J_A, J_C] = computeJacobians(x, input, coeff);
% [J_A, J_C] = numericalJacobians(x, input, coeff);
% evolve the system
xDot = jetModel.get_xDot(x, coeff, input);
% compute the Kalman Gain
K = P*J_C'/(config.ekf.measurement_noise);
% correct the estimation
xhatDot = xDot + K*(measurement - J_C*x);
% evolve the covariance derivative
Pdot = J_A*P + P*J_A' + config.ekf.process_noise - P*J_C'/(config.ekf.measurement_noise)*J_C*P;
end
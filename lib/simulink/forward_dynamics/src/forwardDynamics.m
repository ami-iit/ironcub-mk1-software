function [v_b, omega_b, joints_velocity, dot_v_b, dot_omega_b, joint_acceleration] ...
          = forwardDynamics(mass_matrix, bias_forces, base_velocity, joints_velocity, joints_torque, generalized_ext_wrench, Config)
    
%% compute forwar dynamics as a first order system
% M \dot{v} + h = S*tau + external_forces
% state x = [x1, x2] 
% dot{x} = [x2;...
%           dot{v}];
% dot{v} = inv{M}(S*tau + external_forces - h)

S = [zeros(6, Config.N_DOF);...
         eye(Config.N_DOF)];

% base and joint acceleration 
dot_v = mass_matrix\(S*joints_torque + generalized_ext_wrench - bias_forces); 

v_b = base_velocity(1:3);
omega_b = base_velocity(4:6);
dot_v_b = dot_v(1:3);
dot_omega_b = dot_v(4:6);
joint_acceleration = dot_v(7:end);
end

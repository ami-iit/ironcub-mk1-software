function [throttle, error]  = fl_single_jet_control(int, int_dot, int_dot_des, jet_coefficients, integral_err)

% jet state [T, dot{T}];
x = [int, int_dot];

% collect dynamics quantities for every jet
f_jet = iRonCubLib.get_f(x, jet_coefficients);
g_jet = iRonCubLib.get_g(x, jet_coefficients);
B_UU = jet_coefficients(9);

error = int_dot - int_dot_des;

% v should be bounded. Exploit the mapping v = u + B_UU*u^2;
u_max = Config.jet.u_max;
u_min = Config.jet.u_min;
v_max = (u_max + B_UU*u_max^2);
v_min = (u_min + B_UU*u_min^2);

% compute fl control law for the virtual input v
v_i = - (Config.fl.KP*error + f_jet + Config.fl.KI*integral_err)/g_jet;

% saturate the computed input
v_i = max(v_min, min(v_i, v_max));

% find the real input u
delta = max(1 + 4*B_UU*v_i, 0);
throttle = ( -1 + sqrt(delta))/( 2*B_UU );
end

function [throttle, error]  = fl_jets_control(jets, jets_dot, jets_dot_des, Config, integral_err)

% jet state [T, dot{T}];
x = [jets, jets_dot];

% initialize throttle
throttle = zeros(4,1);

% initialize thrust rate-of-change error
error = zeros(4,1);

% for every jet
for i=1:4
    % collect dynamics quantities for every jet
    f_jet_i = iRonCubLib.get_f(x(i,:), Config.jet.coeff(i,:));
    g_jet_i = iRonCubLib.get_g(x(i,:), Config.jet.coeff(i,:));
    B_UU_i = Config.jet.coeff(i,9);
    
    error(i) = jets_dot(i) - jets_dot_des(i);
     
    % v should be bounded. Exploit the mapping v = u + B_UU*u^2;
    u_max = Config.jet.u_max;
    u_min = Config.jet.u_min;
    v_max = (u_max + B_UU_i*u_max^2);
    v_min = (u_min + B_UU_i*u_min^2);
    
    % compute fl control law for the virtual input v
    v_i = - (Config.fl.KP(i)*error(i) + f_jet_i + Config.fl.KI(i)*integral_err(i))/g_jet_i;
    
    % saturate the computed input
    v_i = max(v_min, min(v_i, v_max));
    
    % find the real input u
    delta = max(1 + 4*B_UU_i*v_i, 0);
    throttle(i) = ( -1 + sqrt(delta))/( 2*B_UU_i );
    
end
end



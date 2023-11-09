%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%              COMMON *JETS* CONFIGURATION PARAMETERS                     %
%                                                                         %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% workaround to fix a problem with EKF and jet control parameters (there is
% no distinction there between P100 and P160)
Config.jetC_P100 = Config.jetC_P160;
                  
% Just rewriting the coefficients in a different data structure: it is
% simpler to handle in the fl controller.
%
Config.jet.coeff         = [Config.jetC_P100; ...
                            Config.jetC_P100; ...
                            Config.jetC_P220; ...
                            Config.jetC_P220];
 
jets_config.coefficients = [Config.jetC_P100; ...
                            Config.jetC_P100; ...
                            Config.jetC_P220; ...
                            Config.jetC_P220];

% jets intial conditions
jets_config.init_thrust              = zeros(4,1);
Config.initT                         = 10.0;
Config.initTdot                      = 0.0;
Config.initialConditions.jets_thrust = 0.0;

% If TRUE, the thrust rate of change for jet control is estimated by
% relying on a dedicated EKF, and not taken from the momentum-based 
% EKF-thrust estimator
Config.TDot_for_jetControl_estimatedInternally = false;

% Jet control internal EKF parameters
Config.ekf.initP             = [10, 1; 1, 10] * 1e-1;
Config.ekf.process_noise     = [10, 1; 1, 10] * 1e-1;
Config.ekf.measurement_noise = 10e2 * 1e1;

% Thrust Gaussian noise, if we need it
%
% Note that I'm assuming that the noise does not affect the system but just 
% the "measurement". If the noise is not zero you should tune the EKF 
% parameters above
Config.thrust_noise = 0.0;

%% Gains for Jet Control

% T jet control
Config.fl.KP = [1, 1, 1, 1] * 50 ;
Config.fl.KD = 2 * sqrt(Config.fl.KP);
Config.fl.KI = [1, 1, 1, 1] * 0;

% Saturation on throttle
Config.jet.u_max = 120;
Config.jet.u_min = 0;

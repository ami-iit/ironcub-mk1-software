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

Config.jet.coeff = [Config.jetC_P100; ...
                    Config.jetC_P100; ...
                    Config.jetC_P220; ...
                    Config.jetC_P220];

jets_config.coefficients = [Config.jetC_P100; ...
                            Config.jetC_P100; ...
                            Config.jetC_P220; ...
                            Config.jetC_P220];

jets_config.init_thrust = Config.initialConditions.jets_thrust;

% jets intial conditions
Config.initT = 0.0;
Config.initTdot = 0.0;

% EKF parameters
Config.ekf.initP = [10, 1; 1, 10] * 1e-1;
Config.ekf.process_noise = [10, 1; 1, 10] * 1e-0;
Config.ekf.measurement_noise = 10e2 * 1e-3; %% in simulation there's no noise

% Thrust Gaussian noise, if we need it
% Note that I'm assuming that the noise does not affect the system but just the "measurement"
% If the noise is not zero you should tune the EKF parameters above
Config.thrust_noise = 0.0;

Config.fl.KP = [1, 1, 1, 1] * 50 ;
Config.fl.KD = 2 * sqrt(Config.fl.KP);
Config.fl.KI = [1, 1, 1, 1] * 0;

% Saturation on throttle
Config.jet.u_max = 120;
Config.jet.u_min = 0;

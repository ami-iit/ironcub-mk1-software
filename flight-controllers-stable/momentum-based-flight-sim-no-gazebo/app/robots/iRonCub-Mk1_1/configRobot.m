%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%              COMMON ROBOT CONFIGURATION PARAMETERS                      %
%                                                                         %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% General robot model information
Config.N_DOF         = 23;
Config.N_DOF_MATRIX  = eye(Config.N_DOF);
Config.ON_GAZEBO     = true;
Config.GRAVITY_ACC   = 9.81;

% 4 element list identifying jets'axes: The value can be either 1,2,3 and
% it identifies the axes x,y,z of the associated end effector frame. The
% sign identifies the direction.
Config.jets.axes     =  zeros(4,1);
Config.jets.axes(1)  = -3;
Config.jets.axes(2)  = -3;
Config.jets.axes(3)  = -3;
Config.jets.axes(4)  = -3;

% Robot configuration for WBToolbox
WBTConfigRobot           = WBToolbox.Configuration;
WBTConfigRobot.RobotName = 'icubSim';
WBTConfigRobot.UrdfFile  = 'model.urdf';
WBTConfigRobot.LocalName = 'WBT';

% Controlboards and joints list. Each joint is associated to the corresponding controlboard
WBTConfigRobot.ControlBoardsNames     = {'torso','left_arm','right_arm','left_leg','right_leg'};
WBTConfigRobot.ControlledJoints       = [];
Config.numOfJointsForEachControlboard = [];

ControlBoards                                        = struct();
ControlBoards.(WBTConfigRobot.ControlBoardsNames{1}) = {'torso_pitch','torso_roll','torso_yaw'};
ControlBoards.(WBTConfigRobot.ControlBoardsNames{2}) = {'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow'};
ControlBoards.(WBTConfigRobot.ControlBoardsNames{3}) = {'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow'};
ControlBoards.(WBTConfigRobot.ControlBoardsNames{4}) = {'l_hip_pitch','l_hip_roll','l_hip_yaw','l_knee','l_ankle_pitch','l_ankle_roll'};
ControlBoards.(WBTConfigRobot.ControlBoardsNames{5}) = {'r_hip_pitch','r_hip_roll','r_hip_yaw','r_knee','r_ankle_pitch','r_ankle_roll'};

% specify the joints
jointOrder = {'torso_pitch', 'torso_roll', 'torso_yaw', ...
            'l_shoulder_pitch', 'l_shoulder_roll', 'l_shoulder_yaw', 'l_elbow', ...
            'r_shoulder_pitch', 'r_shoulder_roll', 'r_shoulder_yaw', 'r_elbow', ...
            'l_hip_pitch', 'l_hip_roll', 'l_hip_yaw', 'l_knee', 'l_ankle_pitch', 'l_ankle_roll', ...
            'r_hip_pitch', 'r_hip_roll', 'r_hip_yaw', 'r_knee', 'r_ankle_pitch', 'r_ankle_roll'};

for n = 1:length(WBTConfigRobot.ControlBoardsNames)

    WBTConfigRobot.ControlledJoints       = [WBTConfigRobot.ControlledJoints, ControlBoards.(WBTConfigRobot.ControlBoardsNames{n})];
    Config.numOfJointsForEachControlboard = [Config.numOfJointsForEachControlboard; length(ControlBoards.(WBTConfigRobot.ControlBoardsNames{n}))];
end

% Joints limits list. Limits are scaled by a safety range (smaller than the
% normal joints limit range)
scaleTorsoJointsLimits = 0.7;
scaleArmsJointsLimits  = 0.8;
scaleLegsJointsLimits  = 0.5;

torsoJointsLimit       = scaleTorsoJointsLimits * [-20, 70; -30, 30; -50, 50];
armsJointsLimit        = scaleArmsJointsLimits * [-90, 10; 0, 160; -35, 80; 15, 105];
legsJointsLimit        = scaleLegsJointsLimits *[-35, 80; -15, 90; -70, 70; -100, 0; -30, 30; -20, 20];

Config.sat.jointPositionLimits = [torsoJointsLimit;          % torso
                                  armsJointsLimit;           % larm
                                  armsJointsLimit;           % rarm
                                  legsJointsLimit;           % lleg
                                  legsJointsLimit] * pi/180; % rleg

% Added for the Gazebo-free environment.

% Initial condition of iRonCub and for the integrators.
Config.initialConditions.base_position = [0;0;0.8];
Config.initialConditions.orientation   = diag([-1,-1,1]);
Config.initialConditions.world_H_base  = Rp2Hom(Config.initialConditions.orientation, Config.initialConditions.base_position);
Config.initialConditions.joints        = [0.1744;  0.0007; 0.0001; -0.1745; ...
                                          0.4363;  0.6981; 0.2618; -0.1745; ...
                                          0.4363;  0.6981; 0.2618;  0.0003; ...
                                          0.0000; -0.0001; 0.0004; -0.0004; ...
                                          0.0003;  0.0002; 0.0001; -0.0002; ...
                                          0.0004; -0.0005; 0.0003];

Config.initialConditions.base_linear_velocity  = [0;0;0];
Config.initialConditions.base_angular_velocity = [0;0;0];
Config.initialConditions.base_velocity         = [Config.initialConditions.base_linear_velocity; Config.initialConditions.base_angular_velocity];
Config.initialConditions.joints_velocity       = zeros(Config.N_DOF,1);
Config.initialConditions.jets_thrust           = [98; 98; 113; 113];

% foot print of the feet (iCub)
vertex = zeros(3, 4);
vertex(:, 1) = [-0.06; 0.04; 0];
vertex(:, 2) = [0.11; 0.04; 0];
vertex(:, 3) = [0.11; -0.035; 0];
vertex(:, 4) = [-0.06; -0.035; 0];

contact_config.foot_print = vertex;
contact_config.total_num_vertices = size(vertex,2)*2;

% friction coefficient for the feet
Config.friction_coefficient = 0.1;

% structure used to configure the Contacts class
contact_config.foot_print = vertex;
contact_config.friction_coefficient = Config.friction_coefficient;

% structure used to configure the Robot class
robot_config = Config;
robot_config.jointOrder = jointOrder;
robot_config.initialConditions.w_H_b = Config.initialConditions.world_H_base;
robot_config.initialConditions.s = Config.initialConditions.joints;
robot_config.initialConditions.base_pose_dot = Config.initialConditions.base_velocity;
robot_config.initialConditions.s_dot = Config.initialConditions.joints_velocity;

% Reflected inertia
robot_config.SIMULATE_MOTOR_REFLECTED_INERTIA = false;

% robot name and path
robot_config.robotName = robotName;
component_path         = getenv('IRONCUB_COMPONENT_SOURCE_DIR');
robot_config.fileName  = 'model_stl.urdf';
robot_config.modelPath = [component_path '/models/' robot_config.robotName '/iRonCub/robots/' robot_config.robotName '/'];

% structure used to configure the Contacts class
contact_config.foot_print = vertex;
contact_config.friction_coefficient = Config.friction_coefficient;

% Robot frames list
Frames.BASE_LINK        = 'root_link';
Frames.JET1_FRAME       = 'l_arm_jet_turbine';
Frames.JET2_FRAME       = 'r_arm_jet_turbine';
Frames.JET3_FRAME       = 'chest_l_jet_turbine';
Frames.JET4_FRAME       = 'chest_r_jet_turbine';
Frames.COM_FRAME        = 'com';
Frames.LFOOT_FRAME      = 'l_sole';
Frames.RFOOT_FRAME      = 'r_sole';

% Robot frames list - repeated in the simulator 
Frames.BASE       = 'root_link';
Frames.COM        = 'com';
Frames.LEFT_FOOT  = 'l_sole';
Frames.RIGHT_FOOT = 'r_sole';


% Robot ports list
Ports.BASE_STATE        = '/icubSim/floating_base/state:o';
Ports.THRUST_RATIO      = '/icub-jets/jets/input:i';
Ports.JETS_THRUSTS      = '/icub-jets/jets/thrust:o';
Ports.WRENCH_LEFT_FOOT  = '/wholeBodyDynamics/left_foot/cartesianEndEffectorWrench:o';
Ports.WRENCH_RIGHT_FOOT = '/wholeBodyDynamics/right_foot/cartesianEndEffectorWrench:o';
Ports.JOYSTICK_AXIS     = '/joypadDevice/xbox/axis:o';
Ports.JOYSTICK_BUTTONS  = '/joypadDevice/xbox/buttons:o';

robot_config.robotFrames = Frames;

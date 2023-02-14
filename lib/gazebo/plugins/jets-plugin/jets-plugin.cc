// Copyright (C) 2018 Fondazione Istituto Italiano di Tecnologia (IIT)
// All Rights Reserved.

#include <jet-plugin.h>
#include <yarp/os/BufferedPort.h>
#include <yarp/os/Network.h>
#include <yarp/sig/Vector.h>

#include <boost/bind/bind.hpp>
#include <gazebo/common/Events.hh>
#include <gazebo/common/Plugin.hh>
#include <gazebo/physics/Link.hh>
#include <gazebo/physics/Model.hh>
#include <gazebo/physics/World.hh>

using namespace gazebo;

// Register this plugin with the simulator
GZ_REGISTER_MODEL_PLUGIN(Jets)

Jets::Jets() {}

Jets::~Jets() {
  Jets::CloseViz();
  m_inputPort.interrupt();
  m_inputPort.close();
  yarp::os::Network::fini();
}

inline uint64_t Jets::convertJetsIndexToJetsMarkerId(const uint64_t jetsIndex) {
  return jetsIndex + 1;
}

bool Jets::addGazeboEnviromentalVariablesModel(
    gazebo::physics::ModelPtr _parent, sdf::ElementPtr _sdf,
    yarp::os::Property &plugin_parameters) {
  // Prefill the property object with some gazebo-yarp-plugins "Enviromental
  // Variables" (not using the env variable in fromConfigFile(const ConstString&
  // fname, Searchable& env, bool wipe) method because we want the variable
  // defined here to be overwritable by the user configuration file
  std::string gazeboYarpPluginsRobotName = _parent->GetName();
  plugin_parameters.put("gazeboYarpPluginsRobotName",
                        gazeboYarpPluginsRobotName.c_str());
  return true;
}

bool Jets::loadConfigModelPlugin(gazebo::physics::ModelPtr _model,
                                 sdf::ElementPtr _sdf,
                                 yarp::os::Property &plugin_parameters) {
  if (_sdf->HasElement("yarpConfigurationFile")) {
    std::string ini_file_name = _sdf->Get<std::string>("yarpConfigurationFile");
    std::string ini_file_path =
        gazebo::common::SystemPaths::Instance()->FindFileURI(ini_file_name);

    Jets::addGazeboEnviromentalVariablesModel(_model, _sdf, plugin_parameters);

    bool wipe = false;
    if (ini_file_path != "" &&
        plugin_parameters.fromConfigFile(ini_file_path.c_str(), wipe)) {
      return true;
    } else {
      gzerr << "GazeboYarpPlugins error: failure in loading configuration for "
               "model"
            << _model->GetName() << "\n"
            << "GazeboYarpPlugins error: yarpConfigurationFile : "
            << ini_file_name << "\n"
            << "GazeboYarpPlugins error: yarpConfigurationFile absolute path : "
            << ini_file_path;
      return false;
    }
  }
  return true;
}

inline bool Jets::hasEnding(std::string const &fullString,
                            std::string const &ending) {
  if (fullString.length() >= ending.length()) {
    return (0 == fullString.compare(fullString.length() - ending.length(),
                                    ending.length(), ending));
  } else {
    return false;
  }
}

void Jets::Load(physics::ModelPtr _parent, sdf::ElementPtr _sdf) {
  // Store the pointer to the model
  this->m_model = _parent;

  yarp::os::Network::init();

  if (!yarp::os::Network::checkNetwork(5.0)) {
    gzerr << "[Jets::loadConfigModelPlugin] yarp network does not seem to be "
             "available, is the "
             "yarpserver running?";
    return;
  }

  if (!_parent) {
    gzerr << "[Jets::loadConfigModelPlugin] Jets plugin requires a parent.\n";
    return;
  }

  bool ok = Jets::loadConfigModelPlugin(_parent, _sdf, m_pluginParameters);
  if (!ok) {
    return;
  }

  ok = Jets::ParseParameters();
  if (!ok) {
    return;
  }

  // Resize and initialize buffers
  m_lastInput.resize(m_linkJetsNames.size());
  m_currentThrustInN.resize(m_linkJetsNames.size());
  m_currentDerivativeThrust.resize(m_linkJetsNames.size());

  m_lastInput = 0.0;
  m_currentThrustInN = 0.0;
  m_currentDerivativeThrust = 0.0;

#if GAZEBO_MAJOR_VERSION >= 8
  m_lastUpdateSimTime = m_model->GetWorld()->SimTime();
#else
  m_lastUpdateSimTime = m_model->GetWorld()->GetSimTime();
#endif

  // Open the input port
  ok = m_inputPort.open(m_inputPortName.c_str());

  if (!ok) {
    gzerr << "[Jets::loadConfigModelPlugin] Impossible to open YARP port "
          << m_inputPortName << " .\n";
    return;
  }

  // Open the thrust output port
  ok = m_thrustPort.open(m_thrustPortName.c_str());

  if (!ok) {
    gzerr << "[Jets::loadConfigModelPlugin] Impossible to open YARP port "
          << m_thrustPortName << " .\n";
    return;
  }

  // Open the thrust rate-of-change output port
  ok = m_d_thrustPort.open(m_d_thrustPortName.c_str());

  if (!ok) {
    gzerr << "[Jets::loadConfigModelPlugin] Impossible to open YARP port "
          << m_d_thrustPortName << " .\n";
    return;
  }

  // Load the visualization
  Jets::LoadViz();

  // Listen to the update event. This event is broadcast every
  // simulation iteration.
  this->m_updateConnection = event::Events::ConnectWorldUpdateBegin(
      boost::bind(&Jets::OnUpdate, this, boost::placeholders::_1));

  // Connect the OnReset method to the WorldReset event callback
  this->m_resetConnection = gazebo::event::Events::ConnectWorldReset(
      boost::bind(&Jets::OnReset, this));
}

bool Jets::ParseParameters() {
  // Parse input-port-prefix option
  if (!m_pluginParameters.check("input-port-name") ||
      !(m_pluginParameters.find("input-port-name").isString())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading input-port-name "
             "parameters"
          << std::endl;
  }

  m_inputPortName =
      m_pluginParameters.find("input-port-name").asString().c_str();

  // Parse thrust-port-prefix option
  if (!m_pluginParameters.check("thrust-port-name") ||
      !(m_pluginParameters.find("thrust-port-name").isString())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading thrust-port-name "
             "parameters"
          << std::endl;
  }

  m_thrustPortName =
      m_pluginParameters.find("thrust-port-name").asString().c_str();

  if (!m_pluginParameters.check("d_thrust-port-name") ||
      !(m_pluginParameters.find("d_thrust-port-name").isString())) {
    gzerr << "Jets : error loading thrust-rate-of-change-port-name parameters"
          << std::endl;
  }

  m_d_thrustPortName =
      m_pluginParameters.find("d_thrust-port-name").asString().c_str();

  // Parse max-thrust-in-N option
  yarp::os::Bottle max_thrust_bottle =
      m_pluginParameters.findGroup("max-thrust-in-N");

  if (max_thrust_bottle.isNull() || !(max_thrust_bottle.get(1).isList())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading max-thrust-in-N"
          << std::endl;
    return false;
  }

  // Select the max-thrust list from the max_thrust_bottle
  yarp::os::Bottle *maxThrustList = max_thrust_bottle.get(1).asList();

  // Number of jets
  int nr_of_jets = maxThrustList->size();

  m_maxThrustInN.resize(nr_of_jets);

  // Update m_maxThrustInN with the thrust limit of each jet
  for (size_t i = 0; i < nr_of_jets; i++) {
    m_maxThrustInN[i] = maxThrustList->get(i).asFloat64();

    // check if the i-th max thrust is > 0
    if (m_maxThrustInN[i] < 0) {
      gzerr << "[Jets::loadConfigModelPlugin] max-thrust-in-N must be >= 0"
            << std::endl;
      return false;
    }
  }

  // Parse jets coefficients
  yarp::os::Bottle jets_coefficients_bottle =
      m_pluginParameters.findGroup("jet-coefficients");

  if (jets_coefficients_bottle.isNull() ||
      !(jets_coefficients_bottle.get(1).isList())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading parameters"
          << std::endl;
    return false;
  }

  yarp::os::Bottle *jetsCoefficientsList =
      jets_coefficients_bottle.get(1).asList();

  yarp::os::Bottle *JetParameters = jetsCoefficientsList->get(0).asList();
  int nr_of_coefficients = JetParameters->size();

  m_jetCoefficients.resize(nr_of_jets);

  for (size_t jet_i = 0; jet_i < nr_of_jets; jet_i++) {
    yarp::os::Bottle *currentJetParameters =
        jetsCoefficientsList->get(jet_i).asList();
    m_jetCoefficients[jet_i].resize(nr_of_coefficients);
    for (size_t i_coeff = 0; i_coeff < nr_of_coefficients; i_coeff++) {
      m_jetCoefficients[jet_i][i_coeff] =
          currentJetParameters->get(i_coeff).asFloat64();
    }
  }

  gzmsg << "[Jets::loadConfigModelPlugin] Jet Coefficients imported"
        << std::endl;

  for (size_t i = 0; i < nr_of_jets; i++) {
    gzmsg << "Jet nr. : " << i + 1 << " [ ";
    for (auto j : m_jetCoefficients[i]) {
      gzmsg << j << " ";
    }
    gzmsg << "]" << std::endl;
  }

  // Parse inverse-time-constant-in-one-over-seconds option
  if (!m_pluginParameters.check("inverse-time-constant-in-one-over-seconds") ||
      !(m_pluginParameters.find("inverse-time-constant-in-one-over-seconds")
            .isFloat64())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading "
             "inverse-time-constant-in-one-over-seconds"
          << std::endl;
  }

  m_inverseTimeConstantInOneOverSeconds =
      m_pluginParameters.find("inverse-time-constant-in-one-over-seconds")
          .asFloat64();

  // Parse the jet-axis option
  yarp::os::Bottle jet_axis_bottle = m_pluginParameters.findGroup("jet-axis");

  if (jet_axis_bottle.isNull() || !(jet_axis_bottle.get(1).isList())) {
    gzerr << "[Jets::loadConfigModelPlugin] error loading jet-axis"
          << std::endl;
    return false;
  }

  // Select the jet axis list from the jet_axis_bottle
  yarp::os::Bottle *jetAxisList = jet_axis_bottle.get(1).asList();

  // Check if the jet-axis list and the list of max-thrust contains the same
  // number of jets, and are therfore consistent
  if (nr_of_jets != jetAxisList->size()) {
    gzerr << "[Jets::loadConfigModelPlugin] malformed config file. "
             "max-thrust-in-N and jet-axis must "
             "have the same number of elements "
          << std::endl;
    return false;
  }

  // m_jetAxis represents the following matrix:
  //
  //    [axis_jet_1,
  //     axis_jet_2,
  //        ...
  //     axis_jet_n]
  //
  // where axis_jet_i is a (1 x 3) vector representing the i-th jet axis.

  // Update m_jetAxis
  //
  // TODO(nava) throw an error if the input is not a valid axis
  m_jetAxis.resize(nr_of_jets);

  for (size_t i = 0; i < nr_of_jets; i++) {
    yarp::os::Bottle *currentJetAxis = jetAxisList->get(i).asList();

    for (size_t i_axis = 0; i_axis < 3; i_axis++) {
      m_jetAxis[i][i_axis] = currentJetAxis->get(i_axis).asFloat64();
    }
  }

  gzmsg << "[Jets::loadConfigModelPlugin] jet-axis list read.\n";

  // Parsing link-jets option
  yarp::os::Bottle link_Jets_bottle = m_pluginParameters.findGroup("link-jets");

  if (link_Jets_bottle.isNull() || !(link_Jets_bottle.get(1).isList())) {
    gzerr << "[Jets::loadConfigModelPlugin] setJointNames(): Error cannot find "
             "link-jets.";
    return false;
  }

  yarp::os::Bottle *jetsList = link_Jets_bottle.get(1).asList();

  gzmsg << "[Jets::loadConfigModelPlugin] Jets frame list imported"
        << std::endl;

  for (auto i = 0; i < nr_of_jets; i++) {
    gzmsg << jetsList->get(i).asString().c_str() << "\n";
  }

  if (strcmp(DYNTYPE, "nonlinear_dynamics") == 0) {
    m_jetModel = DYNTYPE;
  } else if (strcmp(DYNTYPE, "first_order_dynamics") == 0) {
    m_jetModel = DYNTYPE;
  } else {
    gzmsg << "[Jets::loadConfigModelPlugin] you are using the no dyamics jet "
             "model. The plugin will set the thrust you're sending.\n";
  }

  m_linkJetsNames.resize(nr_of_jets);
  m_linkJetsPointers.resize(nr_of_jets);

  const gazebo::physics::Link_V &gazebo_models_links = m_model->GetLinks();

  for (size_t i = 0; i < m_linkJetsNames.size(); i++) {
    bool joint_found = false;
    std::string linkNameToFind = jetsList->get(i).asString().c_str();

    for (size_t gazebo_link = 0;
         gazebo_link < gazebo_models_links.size() && !joint_found;
         gazebo_link++) {
      std::string gazebo_link_name =
          gazebo_models_links[gazebo_link]->GetName();
      if (Jets::hasEnding(gazebo_link_name, linkNameToFind)) {
        joint_found = true;
        m_linkJetsNames[i] = gazebo_link_name;
        m_linkJetsPointers[i] = this->m_model->GetLink(gazebo_link_name);
      }
    }

    if (!joint_found) {
      gzerr << "[Jets::loadConfigModelPlugin] cannot find link '"
            << linkNameToFind << "' (" << i + 1 << " of " << nr_of_jets << ") "
            << "\n";
      gzerr << "link-jets are " << link_Jets_bottle.toString().c_str() << "\n";
      m_linkJetsNames.resize(0);
      m_linkJetsPointers.resize(0);
      return false;
    }
  }
  return true;
}

// Called by the world update start event
void Jets::OnUpdate(const common::UpdateInfo &_info) {
  // Refresh the last input
  bool shouldWait = false;
  yarp::sig::Vector *input = m_inputPort.read(shouldWait);
  if (input) {
    if (input->size() == m_lastInput.size()) {
      m_lastInput = *input;
    } else {
      gzerr << "[Jets::OnUpdate] Malformed input\n";
    }
  }

  // Update the current thrusts provided by the jets
  // Note: in Gazebo 8, it is not possible to declare a new dynamic system and
  // add it to the physics engine, so we need to have a separate "thrust"
  // integrator to integrate the first order dynamics of the thruster Get the
  // timestep
  double timestepInS = (_info.simTime - m_lastUpdateSimTime).Double();

  if (m_jetModel.compare("nonlinear_dynamics") == 0) {
    Jets::integrateSecondOrderNonlinearDynamics(timestepInS);
  } else if (m_jetModel.compare("first_order_dynamics") == 0) {
    Jets::integrateFirstOrderDynamics(timestepInS);
  } else {
    for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
      m_currentThrustInN[jet] = m_lastInput[jet];
    }
  }

  // Hard limiter
  for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
    if (m_currentThrustInN[jet] <= 0.0) m_currentThrustInN[jet] = 0.0;
    if (m_currentThrustInN[jet] >= m_maxThrustInN[jet])
      m_currentThrustInN[jet] = m_maxThrustInN[jet];
  }

  // Add the thrust force to the links
  for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
    // Reset and update the jetForce vector
    ignition::math::Vector3d jetForce = ignition::math::Vector3d(0.0, 0.0, 0.0);

    // Add jet direction
    for (size_t i_axis = 0; i_axis < 3; i_axis++) {
      jetForce[i_axis] = m_jetAxis[jet][i_axis];
    }

    // Add thrust magnitude
    jetForce = jetForce * m_currentThrustInN(jet);

    // from gazebo documentation
    // [in]	_force	Force to add. The force must be expressed in the
    // link-fixed reference frame. [in]	_offset	Offset position expressed in
    // coordinates of the link frame with respect to the link frame's origin. It
    // defaults to the link origin.
    m_linkJetsPointers[jet]->AddLinkForce(jetForce);
  }

  // Publish the current thrust
  m_thrustPort.prepare() = m_currentThrustInN;
  m_thrustPort.write();

  m_d_thrustPort.prepare() = m_currentDerivativeThrust;
  m_d_thrustPort.write();

  // Update the visualization
  Jets::RunViz();

  // Store the last update time
  m_lastUpdateSimTime = _info.simTime;
}

void Jets::integrateFirstOrderDynamics(const double timestepInS) {
  // Compute the new thrust using a implicit Euler integrator
  //
  // Small derivation of the integrator equation (x: thrust is the state, u the
  // input) ẋ = a x + u x_{k+1} - x_k = (ax_{k+1}+u_{k+1}) Δt x_{k+1} = (a
  // x_{k+1} + u_{k+1}) Δt + x_k x_{k+1} = \frac{u_{k+1} Δt + x_k}{1 - a Δt}
  double a = m_inverseTimeConstantInOneOverSeconds;
  if (a * timestepInS > 1 || timestepInS < 0.0 || a < 0.0) {
    gzerr << "[Jets::OnUpdate] integration error.\n";
  } else {
    for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
      double u = m_lastInput[jet];
      m_currentDerivativeThrust[jet] = m_lastInput[jet];
      double dt = timestepInS;
      m_currentThrustInN[jet] =
          (m_currentThrustInN[jet] + u * dt) / (1 - a * dt);
    }
  }
}

void Jets::integrateSecondOrderNonlinearDynamics(const double timestepInS) {
  // Compute the thurst using the identified second order nonlinear model
  // Integration using Taylor expansion
  // Tₖ₊₁ = Tₖ + Ṫₖ dt + T̈ₖ dt²/2
  // T̈ = K_T⋅T + K_TT⋅T² + K_D⋅Ṫ + K_DD⋅Ṫ² + K_TD⋅TṪ + (B_U + B_T⋅T +
  // B_D⋅Ṫ)⋅(u + B_UU⋅u²)
  if (timestepInS < 0.0) {
    gzerr << "Jets: integration error.\n";
  } else {
    for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
      double u = m_lastInput[jet];
      double dt = timestepInS;

      std::vector<double> K;
      K.resize(m_jetCoefficients[jet].size());
      int idx = 0;
      for (auto i : m_jetCoefficients[jet]) {
        K[idx] = i;
        idx++;
      }
      double current_accThrust =
          K[0] * m_currentThrustInN[jet] +
          K[1] * pow(m_currentThrustInN[jet], 2) +
          K[2] * m_currentDerivativeThrust[jet] +
          K[3] * pow(m_currentDerivativeThrust[jet], 2) +
          K[4] * m_currentThrustInN[jet] * m_currentDerivativeThrust[jet] +
          (K[5] + K[6] * m_currentThrustInN[jet] +
           K[7] * m_currentDerivativeThrust[jet]) *
              (u + K[8] * pow(u, 2)) +
          K[9];

      m_currentThrustInN[jet] = m_currentThrustInN[jet] +
                                m_currentDerivativeThrust[jet] * dt +
                                current_accThrust * pow(dt, 2) / 2;

      m_currentDerivativeThrust[jet] =
          m_currentDerivativeThrust[jet] + current_accThrust * dt;

      if (m_currentThrustInN[jet] <= 0.0) {
        m_currentDerivativeThrust[jet] =
            (std::max)(0.0, m_currentDerivativeThrust[jet]);
      }

      else if (m_currentThrustInN[jet] >= m_maxThrustInN[jet]) {
        m_currentDerivativeThrust[jet] =
            (std::min)(0.0, m_currentDerivativeThrust[jet]);
      }
    }
  }
}

// Called by the world update start event
void Jets::OnReset() {
  // On reset, set the thrust and the inputs to 0.0
  m_lastInput = 0.0;
  m_currentThrustInN = 0.0;
  m_currentDerivativeThrust = 0.0;

#if GAZEBO_MAJOR_VERSION >= 8
  m_lastUpdateSimTime = m_model->GetWorld()->SimTime();
#else
  m_lastUpdateSimTime = m_model->GetWorld()->GetSimTime();
#endif
}

// Initialize visualization of jets
void Jets::LoadViz() {
  // TODO(traversaro): use model-specific namespace to support multiple models
  m_markerMsg.set_ns("Jets");

  // See
  // https://bitbucket.org/osrf/gazebo/src/3ac47b35d6462dea6569b022fe20e6f219ef3794/media/materials/scripts/gazebo.material?at=default&fileviewer=file-view-default
  // for the list of available materials
  ignition::msgs::Material *matMsg = m_markerMsg.mutable_material();
  matMsg->mutable_script()->set_name("Gazebo/RedGlow");
  m_markerMsg.set_action(ignition::msgs::Marker::ADD_MODIFY);
  m_markerMsg.set_type(ignition::msgs::Marker::CYLINDER);

  Jets::RunViz();
}

// Update visualization of jets
void Jets::RunViz() {
  for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
    m_markerMsg.set_id(Jets::convertJetsIndexToJetsMarkerId(jet));

    //  TODO(nava) avoid hard-coded cylinder dimensions?
    double jetOffsetDistance = 0.0025;
    double cylinderDiameter = 0.035;
    double maxCylinderLength = 0.75;

    // In order to make clear the difference of max-thrust between jets (if
    // present), the cylinder lenght is scaled on the max(max-thrust)
    double max_of_maxThrustInN =
        *std::max_element(m_maxThrustInN.begin(), m_maxThrustInN.end());
    double cylinderLength =
        maxCylinderLength * (m_currentThrustInN[jet] / max_of_maxThrustInN);

    // There is the option to add a marker to a visual, but not an easy way to
    // get the visual of a given link from C++, so we just specify directly the
    // pose of the marker as the pose of the link
    ignition::math::Pose3d world_H_link = m_linkJetsPointers[jet]->WorldPose();
    ignition::math::Pose3d link_H_cylinder;
    link_H_cylinder.Reset();

    // We specify also the orientation of the cylinder. By default, the cylinder
    // is oriented with the base lying on the x-y plane of the link reference
    // frame
    ignition::math::Quaternion<double> link_quat_cylinder;
    ignition::math::Vector3d cylinder_origin =
        ignition::math::Vector3d(0, 0, 0);

    // For the moment, it is assumed that the thrust force is applied along one
    // of the link frame axis, therefore the rotation of the cylinder base is
    // hard-coded.
    //
    // TODO(nava) avoid to hard-code the cylinder base orientation.
    if (abs(m_jetAxis[jet][0]) > 0) {
      link_quat_cylinder.Euler(0.0, IGN_PI / 2, 0.0);
      // link_quat_cylinder.Euler(m_jetOrientations[jet][1]+IGN_PI/2,m_jetOrientations[jet][2]+IGN_PI/2,m_jetOrientations[jet][3]+IGN_PI/2);
    } else if (abs(m_jetAxis[jet][1]) > 0) {
      link_quat_cylinder.Euler(0.0, IGN_PI / 2, IGN_PI / 2);
      // link_quat_cylinder.Euler(m_jetOrientations[jet][1]+IGN_PI/2,m_jetOrientations[jet][2]+IGN_PI/2,m_jetOrientations[jet][3]+IGN_PI/2);
    }

    // We also add an offset to make sure that the origin of the link
    // corresponds to one end of the cylinder
    for (size_t i_axis = 0; i_axis < 3; i_axis++) {
      cylinder_origin[i_axis] = m_jetAxis[jet][i_axis];
    }

    cylinder_origin =
        -cylinder_origin * (cylinderLength / 2 + jetOffsetDistance);

    link_H_cylinder.Pos() = cylinder_origin;
    link_H_cylinder.Rot() = link_quat_cylinder;

// Unfortunately for Pose3d objects we have that strange composition rules A_H_C
// = B_H_C*A_H_B See
// https://bitbucket.org/osrf/gazebo/issues/216/pose-addition-and-subtraction-needs-work#comment-18702360
// And
// https://github.com/dic-iit/component_ironcub/issues/212#issuecomment-682367321
// IGNITION_MATH_MAJOR_VERSION value is bugged in Ign Math 4 (see
// https://github.com/ignitionrobotics/ign-math/pull/151) So better to rely on
// Gazebo version instead, as Gazebo 9 only supports Ign Math 4 and Gazebo 11
// Ign Math 6
#if GAZEBO_MAJOR_VERSION >= 11
    ignition::math::Pose3d world_H_cylinder = world_H_link * link_H_cylinder;
#else
    ignition::math::Pose3d world_H_cylinder = link_H_cylinder * world_H_link;
#endif

    ignition::msgs::Set(m_markerMsg.mutable_pose(), world_H_cylinder);

    // Update the cylinder scale
    ignition::math::Vector3d cylinder_scale = ignition::math::Vector3d(
        cylinderDiameter, cylinderDiameter, cylinderLength);

    ignition::msgs::Set(m_markerMsg.mutable_scale(), cylinder_scale);

    // TODO(traversaro) send a single vector instead of a message for each jet
    m_markerNode.Request("/marker", m_markerMsg);
  }
}

// Cleanup visualization of jets
void Jets::CloseViz() {
  m_markerMsg.set_action(ignition::msgs::Marker::DELETE_MARKER);

  for (size_t jet = 0; jet < m_linkJetsPointers.size(); jet++) {
    m_markerMsg.set_id(Jets::convertJetsIndexToJetsMarkerId(jet));

    // TODO(traversaro) send a single vector instead of a message for each jet
    m_markerNode.Request("/marker", m_markerMsg);
  }
}


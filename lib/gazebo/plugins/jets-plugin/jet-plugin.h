#ifndef JETPLUGIN_H
#define JETPLUGIN_H

#include <yarp/os/BufferedPort.h>
#include <yarp/os/Network.h>
#include <yarp/sig/Vector.h>

#include <boost/bind/bind.hpp>
#include <gazebo/common/Events.hh>
#include <gazebo/common/Plugin.hh>
#include <gazebo/physics/Link.hh>
#include <gazebo/physics/Model.hh>
#include <gazebo/physics/World.hh>

namespace gazebo {
/**
 * For a documentation of the parameters supported by the plugin, please see
 * README.md of the software directory.
 */
class Jets : public ModelPlugin {
 public:
  Jets();
  virtual ~Jets();
  inline uint64_t convertJetsIndexToJetsMarkerId(const uint64_t jetsIndex);

  bool addGazeboEnviromentalVariablesModel(
      gazebo::physics::ModelPtr _parent, sdf::ElementPtr _sdf,
      yarp::os::Property &plugin_parameters);

  bool loadConfigModelPlugin(gazebo::physics::ModelPtr _model,
                             sdf::ElementPtr _sdf,
                             yarp::os::Property &plugin_parameters);

  inline bool hasEnding(std::string const &fullString,
                        std::string const &ending);

  void Load(physics::ModelPtr _parent, sdf::ElementPtr _sdf) override;

  void OnUpdate(const common::UpdateInfo &_info);

  void OnReset();

  void integrateFirstOrderDynamics(const double timestepInS);

  void integrateSecondOrderNonlinearDynamics(const double timestepInS);

 private:
  void CloseViz();

  bool ParseParameters();

  void LoadViz();

  void RunViz();

  // Type of jet dynamics
  std::string m_jetModel;

  // Pointer to the model
  gazebo::physics::ModelPtr m_model;

  // Input port
  yarp::os::BufferedPort<yarp::sig::Vector> m_inputPort;

  // Name of the input port
  std::string m_inputPortName;

  // Output ports
  yarp::os::BufferedPort<yarp::sig::Vector> m_thrustPort;
  yarp::os::BufferedPort<yarp::sig::Vector> m_d_thrustPort;

  // Name of the Output ports
  std::string m_thrustPortName;
  std::string m_d_thrustPortName;

  // Names of the links of the jets
  std::vector<std::string> m_linkJetsNames;

  // Pointer to the link of the jets
  std::vector<gazebo::physics::LinkPtr> m_linkJetsPointers;

  // Jets axis vector
  std::vector<ignition::math::Vector3d> m_jetAxis;

  // Pointer to the update event connection
  gazebo::event::ConnectionPtr m_updateConnection;

  // Pointer to the reset event connection
  gazebo::event::ConnectionPtr m_resetConnection;

  // Parameters of the plugin
  yarp::os::Property m_pluginParameters;

  // Last input read from the port in Newton/s
  yarp::sig::Vector m_lastInput;

  // Current thrust provided by the jets in Newtons
  yarp::sig::Vector m_currentThrustInN;

  // Current thrust derivative provided by the jets in Newton/s
  yarp::sig::Vector m_currentDerivativeThrust;

  // Last time at which onUpdate was called
  gazebo::common::Time m_lastUpdateSimTime;

  // Max thurst
  std::vector<double> m_maxThrustInN;

  // Inverse time constant of the jets dynamics
  double m_inverseTimeConstantInOneOverSeconds;

  // Ignition node for publishing visualization information
  ignition::transport::Node m_markerNode;

  // Ignition msg for publishing visualization information
  ignition::msgs::Marker m_markerMsg;

  // Jet coefficients for the non linear model of the jet
  std::vector<std::vector<double>> m_jetCoefficients;
};
};  // namespace gazebo

#endif  // JETPLUGIN_H

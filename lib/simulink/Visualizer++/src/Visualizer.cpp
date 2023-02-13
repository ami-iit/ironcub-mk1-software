#include "Visualizer/Visualizer.h"

#include <BlockFactory/Core/Log.h>
#include <BlockFactory/Core/Parameter.h>
#include <BlockFactory/Core/Signal.h>

#include <Eigen/Core>
#include <iDynTree/Core/EigenHelpers.h>

#include <yarp/dev/PolyDriver.h>
#include <yarp/os/LogStream.h>
#include <yarp/os/Network.h>
#include <yarp/os/ResourceFinder.h>
#include <yarp/sig/Vector.h>

using namespace std::chrono_literals;

unsigned ironcub::Visualizer::numberOfParameters()
{
    // The base blockfactory::core::Block class needs parameters (e.g. the ClassName).
    // You must specify here how many more parameters this class needs.
    // Our example needs just one more: the operation to perform.
    return Block::numberOfParameters() + 1;
}

// This method should let BlockInformation know the parameters metadata.
// BlockFactory will use this information to gather the parameters from the active engine.
bool ironcub::Visualizer::parseParameters(blockfactory::core::BlockInformation* blockInfo)
{
    // Create the vector containing the parameters
    const std::vector<blockfactory::core::ParameterMetadata> metadata{
        {/*type=*/blockfactory::core::ParameterType::STRING,
         /*index=*/Block::numberOfParameters(),
         /*rows=*/1,
         /*cols=*/1,
         /*name=*/"ConfigPath"}};

    // Add the parameter metadata into the BlockInformation
    for (const auto& md : metadata) {
        if (!blockInfo->addParameterMetadata(md)) {
            bfError << "Failed to store parameter metadata";
            return false;
        }
    }

    // Ask to the BlockInformation interface to parse the parameters and store them into
    // the protected m_parameters member of the parent blockfactory::core::Block class.
    bool paramParsedOk = blockInfo->parseParameters(m_parameters);

    // Return the outcome of the parameter parsing.
    // If the parsing fails, the execution stops.
    return paramParsedOk;
}

bool ironcub::Visualizer::configureSizeAndPorts(blockfactory::core::BlockInformation* blockInfo)
{
    // The base blockfactory::core::Block class needs to be configured first
    if (!blockfactory::core::Block::configureSizeAndPorts(blockInfo)) {
        return false;
    }

    // Create object that store input and output ports information
    blockfactory::core::Port::Info w_H_b{/*portIndex=*/0,
                                         blockfactory::core::Port::Dimensions{4, 4},
                                         blockfactory::core::Port::DataType::DOUBLE};

    blockfactory::core::Port::Info jointsPosition{
        /*portIndex=*/1,
        std::vector<int>{blockfactory::core::Port::DynamicSize}, // TODO: Change to fixed using the
                                                                 // robot configuration
        blockfactory::core::Port::DataType::DOUBLE};

    blockfactory::core::Port::Info jetsIntensities{
        /*portIndex=*/2,
        std::vector<int>{
            blockfactory::core::Port::DynamicSize}, // TODO: Change to fixed using the # of jets
        blockfactory::core::Port::DataType::DOUBLE};

    // Store together the port information objects
    blockfactory::core::InputPortsInfo inputPortInfo;
    blockfactory::core::OutputPortsInfo outputPortInfo;

    inputPortInfo.push_back(w_H_b);
    inputPortInfo.push_back(jointsPosition);
    inputPortInfo.push_back(jetsIntensities);

    // Store the port information into the BlockInformation
    if (!blockInfo->setPortsInfo(inputPortInfo, {})) {
        bfError << "Failed to configure input / output ports";
        return false;
    }

    return true;
}

bool ironcub::Visualizer::initialize(blockfactory::core::BlockInformation* blockInfo)
{

    if (!Block::initialize(blockInfo)) {
        return false;
    }

    if (!Visualizer::parseParameters(blockInfo)) {
        bfError << "[Visualizer::initialize] Failed to parse parameters.";
        return false;
    }
    // use the resource finder to retrieve the informations
    std::string config;
    if (!m_parameters.getParameter("ConfigPath", config)) {
        bfError << "[Visualizer::initialize] Cannot retrieve .ini configuration file";
        return false;
    }

    yarp::os::ResourceFinder rf = yarp::os::ResourceFinder();
    rf.setDefaultConfigFile(config);
    if(!rf.configure(0, nullptr)){
        bfError << "[Visualizer::initialize] Could not find config file";
        return false;
    }

    if (rf.isNull()) {
        bfError << "[Visualizer::initialize] Empty configuration file.";
        return false;
    }

    iDynTree::Position cameraDeltaPosition;
    if (!(rf.check("cameraDeltaPosition") && rf.find("cameraDeltaPosition").isList()
          && rf.find("cameraDeltaPosition").asList()->size() == 3)) {
        bfError << "[Visualizer::initialize] 'cameraDeltaPosition' option not found or not valid.";
        return false;
    }
    for (size_t idx = 0; idx < 3; idx++) {
        if (!(rf.find("cameraDeltaPosition").asList()->get(idx).isFloat64())) {
            bfError << "[Visualizer::initialize] 'cameraDeltaPosition' entry [ " << idx
                    << " ] is not valid.";
            return false;
        }
        cameraDeltaPosition.setVal(idx,
                                   rf.find("cameraDeltaPosition").asList()->get(idx).asFloat64());
    }

    if (!(rf.check("useFixedCamera") && rf.find("useFixedCamera").isBool())) {
        bfError << "[Visualizer::initialize] 'useFixedCamera' option not found or not valid.";
        return false;
    }
    bool useFixedCamera = rf.find("useFixedCamera").asBool();

    iDynTree::Position fixedCameraTarget;
    if (useFixedCamera) {
        if (!(rf.check("fixedCameraTarget") && rf.find("fixedCameraTarget").isList()
              && rf.find("fixedCameraTarget").asList()->size() == 3)) {
            bfError
                << "[Visualizer::initialize] 'fixedCameraTarget' option not found or not valid.";
            return false;
        }
        for (size_t idx = 0; idx < 3; idx++) {
            if (!(rf.find("fixedCameraTarget").asList()->get(idx).isFloat64())) {
                bfError << "'fixedCameraTarget' entry [ " << idx << " ] is not valid.";
                return false;
            }
            fixedCameraTarget.setVal(idx,
                                     rf.find("fixedCameraTarget").asList()->get(idx).asFloat64());
        }
    }

    if (!(rf.check("maxVisualizationFPS") && rf.find("maxVisualizationFPS").isInt32()
          && rf.find("maxVisualizationFPS").asInt32() > 0)) {
        bfError << "[Visualizer::initialize] 'maxVisualizationFPS' option not found or not valid.";
        return false;
    }
    m_maxVizFPS = rf.find("maxVisualizationFPS").asInt32();

    if (!(rf.check("models") && rf.find("models").isList())) {
        bfError << "[Visualizer::initialize] 'models' option not found or not valid.";
        return false;
    }

    m_modelConfiguration.modelName = rf.find("models").asList()->get(0).asString();

    std::string cameraFocusModel;
    if (!useFixedCamera) {
        if (!(rf.check("cameraFocusModel") && rf.find("cameraFocusModel").isString())) {
            bfError << "[Visualizer::initialize] 'cameraFocusModel' option not found or not valid.";
            return false;
        }
        cameraFocusModel = rf.find("cameraFocusModel").asString();
    }

    if (!(rf.check("modelURDFName") && rf.find("modelURDFName").isString())) {
        bfError << "[Visualizer::initialize] 'modelURDFName' option not found or not valid.";
        return false;
    }
    m_modelConfiguration.urdfFile = rf.find("modelURDFName").asString();

    if (!(rf.check("jointList") && rf.find("jointList").isList())) {
        bfError << "[Visualizer::initialize] 'jointList' option not found or not valid.";
        return false;
    }
    auto jointListBottle = rf.find("jointList").asList();
    for (int i = 0; i < jointListBottle->size(); i++) {
        // check if the elements of the bottle are strings
        if (!jointListBottle->get(i).isString()) {
            bfError
                << "[Visualizer::initialize] in 'jointList' there is a field that is not a string.";
            return false;
        }
        m_modelConfiguration.jointList.push_back(jointListBottle->get(i).asString());
    }

    std::string urdfFilePath = rf.findFile(m_modelConfiguration.urdfFile);
    if (urdfFilePath.empty()) {
        bfError << "[Visualizer::initialize] Failed to find file" << m_modelConfiguration.urdfFile;
        return false;
    }

    auto jetsListBottle = rf.find("jetsFramesList").asList();
    for (auto i = 0; i < jetsListBottle->size(); ++i) {
        if (!jetsListBottle->get(i).isString()) {
            bfError << "[Visualizer::initialize] in 'jetsLinksList' there is a field that is not a "
                       "string.";
            return false;
        }
        m_modelConfiguration.jetsFramesList.push_back(jetsListBottle->get(i).asString());
    }
    m_modelConfiguration.jetsIntensities.resize(jetsListBottle->size());

    if (!(rf.check("maxJetsIntensityinN") && rf.find("maxJetsIntensityinN").isInt32()
          && rf.find("maxJetsIntensityinN").asFloat64() > 0)) {
        bfError << "[Visualizer::initialize] 'maxJetsIntensityinN' option not found or not valid.";
        return false;
    }
    m_maxJetsInt = rf.find("maxJetsIntensityinN").asFloat64();

    iDynTree::ModelLoader modelLoader;
    if (!modelLoader.loadReducedModelFromFile(urdfFilePath, m_modelConfiguration.jointList)
        || !modelLoader.isValid()) {
        bfError << "[Visualizer::initialize] Failed to load model" << urdfFilePath;
        return false;
    }
    m_modelConfiguration.model = modelLoader.model();
    m_modelConfiguration.joints.resize(m_modelConfiguration.model.getNrOfDOFs());

    iDynTree::VisualizerOptions options;
    m_viz.init(options);
    m_viz.camera().setPosition(cameraDeltaPosition);
    m_viz.camera().setTarget(fixedCameraTarget);
    m_viz.camera().animator()->enableMouseControl(true);
    m_viz.addModel(m_modelConfiguration.model, m_modelConfiguration.modelName);

    // setting jets
    m_viz.modelViz(m_modelConfiguration.modelName)
        .jets()
        .setJetsFrames(m_modelConfiguration.jetsFramesList);
    m_viz.modelViz(m_modelConfiguration.modelName).jets().setJetsDimensions(0.02, 0.1, 0.3);
    m_viz.modelViz(m_modelConfiguration.modelName)
        .jets()
        .setJetDirection(0, iDynTree::Direction(0, 0, 1.0));
    m_viz.modelViz(m_modelConfiguration.modelName)
        .jets()
        .setJetDirection(1, iDynTree::Direction(0, 0, 1.0));
    m_viz.modelViz(m_modelConfiguration.modelName)
        .jets()
        .setJetDirection(2, iDynTree::Direction(0, 0, 1.0));
    m_viz.modelViz(m_modelConfiguration.modelName)
        .jets()
        .setJetDirection(3, iDynTree::Direction(0, 0, 1.0));

    iDynTree::ColorViz orangeJet{1.0, 0.6, 0.1, 0.0};
    m_viz.modelViz(m_modelConfiguration.modelName).jets().setJetColor(0, orangeJet);
    m_viz.modelViz(m_modelConfiguration.modelName).jets().setJetColor(1, orangeJet);
    m_viz.modelViz(m_modelConfiguration.modelName).jets().setJetColor(2, orangeJet);
    m_viz.modelViz(m_modelConfiguration.modelName).jets().setJetColor(3, orangeJet);

    // setting time counters
    m_now = std::chrono::steady_clock::now();
    m_lastViz = std::chrono::steady_clock::now();
    m_minimumMicroSecViz = std::round(1e6 / (double) m_maxVizFPS);

    return true;
}

bool ironcub::Visualizer::output(const blockfactory::core::BlockInformation* blockInfo)
{
    // Get the input signals
    blockfactory::core::InputSignalPtr w_H_b_input = blockInfo->getInputPortSignal(/*index=*/0);
    blockfactory::core::InputSignalPtr jointsPositionInput =
        blockInfo->getInputPortSignal(/*index=*/1);
    blockfactory::core::InputSignalPtr jetsIntensitiesInput =
        blockInfo->getInputPortSignal(/*index=*/2);

    if (!w_H_b_input || !jointsPositionInput || !jetsIntensitiesInput) {
        bfError << "[Visualizer::output] Input signal not valid.";
        return false;
    }

    // Joints position
    if (jointsPositionInput) {
        // Get the buffer
        const double* buffer = jointsPositionInput->getBuffer<double>();
        if (!buffer) {
            bfError << "Failed to read joints positions from input port.";
            return false;
        }
        // Fill the data
        for (unsigned i = 0; i < jointsPositionInput->getWidth(); ++i) {
            m_modelConfiguration.joints.setVal(i, buffer[i]);
        }
    }

    // Base Pose
    using Matrix4dSimulink = Eigen::Matrix<double, 4, 4, Eigen::ColMajor>;

    if (w_H_b_input) {
        // Get the buffer
        const double* buffer = w_H_b_input->getBuffer<double>();
        if (!buffer) {
            bfError << "Failed to read the base pose from input port.";
            return false;
        }
        // Fill the data
        iDynTree::fromEigen(m_modelConfiguration.basePose, Matrix4dSimulink(buffer));
    }

    // Jets intensities
    if (jetsIntensitiesInput) {
        // Get the buffer
        const double* buffer = jetsIntensitiesInput->getBuffer<double>();
        if (!buffer) {
            bfError << "Failed to read jets intensities from input port.";
            return false;
        }
        // Fill the data
        for (unsigned i = 0; i < jetsIntensitiesInput->getWidth(); ++i) {
            m_modelConfiguration.jetsIntensities.setVal(i, buffer[i] / m_maxJetsInt);
        }
    }

    //  Draw the figure if the max FPS is fullfilled
    if (m_viz.run()) {
        m_now = std::chrono::steady_clock::now();
        if (std::chrono::duration_cast<std::chrono::microseconds>(m_now - m_lastViz).count()
            < m_minimumMicroSecViz) {
            // std::this_thread::sleep_for(1ms); // TODO: check if useful
            return true;
        }

        // setting robot conf
        m_viz.modelViz(m_modelConfiguration.modelName)
            .setPositions(m_modelConfiguration.basePose, m_modelConfiguration.joints);

        // setting jets intensities
        m_viz.modelViz(m_modelConfiguration.modelName)
            .jets()
            .setJetsIntensity(m_modelConfiguration.jetsIntensities);

        m_viz.draw();
        m_lastViz = std::chrono::steady_clock::now();
    }
    else {
        // When the visualizer window is exited, closes the simulation with an error.
        bfError << "Visualization closed.";
        return false;
    }

    return true;
}

bool ironcub::Visualizer::terminate(const blockfactory::core::BlockInformation* /*blockInfo*/)
{
    m_viz.close();
    return true;
}

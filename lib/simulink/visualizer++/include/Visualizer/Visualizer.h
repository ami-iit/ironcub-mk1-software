#ifndef VISUALIZER_H
#define VISUALIZER_H

#include <BlockFactory/Core/Block.h>
#include <BlockFactory/Core/BlockInformation.h>
#include <chrono>
#include <iDynTree/ModelIO/ModelLoader.h>
#include <iDynTree/Visualizer.h>
typedef struct
{
    std::string urdfFile;
    std::string modelName;
    std::vector<std::string> jointList;
    iDynTree::Model model;
    iDynTree::VectorDynSize joints;
    iDynTree::VectorDynSize forcesContactPoints;
    iDynTree::Transform wHb;
    iDynTree::Transform basePose;
    iDynTree::Position basePosition;
    std::vector<std::string> jetsFramesList;
    iDynTree::VectorDynSize jetsIntensities;
} modelConf_t;

namespace ironcub {
    class Visualizer;
}

class ironcub::Visualizer : public blockfactory::core::Block
{
private:
    iDynTree::Visualizer m_viz;
    modelConf_t m_modelConfiguration;
    std::chrono::steady_clock::time_point m_now;
    std::chrono::steady_clock::time_point m_lastViz;
    unsigned int m_maxVizFPS;
    long m_minimumMicroSecViz;
    double m_maxJetsInt;

public:
    Visualizer() = default;
    ~Visualizer() override = default;

    unsigned numberOfParameters() override;
    bool parseParameters(blockfactory::core::BlockInformation* blockInfo) override;
    bool configureSizeAndPorts(blockfactory::core::BlockInformation* blockInfo) override;
    bool initialize(blockfactory::core::BlockInformation* blockInfo) override;
    bool output(const blockfactory::core::BlockInformation* blockInfo) override;
    bool terminate(const blockfactory::core::BlockInformation* blockInfo) override;
};

#endif // VISUALIZER_H

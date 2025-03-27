#include <Visualizer/Visualizer.h>

// Class factory API
#include <sharedlibpp/SharedLibraryClassApi.h>

// Add the example::SignalMath class to the plugin factory
SHLIBPP_DEFINE_SHARED_SUBCLASS(iDynTreeVisualizer, ironcub::Visualizer, blockfactory::core::Block);

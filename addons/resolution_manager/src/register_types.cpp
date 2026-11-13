
#include "register_types.h"
#include "resolution_manager.h"

#include <godot_cpp/godot.hpp>

void initialize_resolution_manager(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<ResolutionManager>();
}

void uninitialize_resolution_manager(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
GDExtensionBool GDE_EXPORT resolution_manager_library_init(
    GDExtensionInterfaceGetProcAddress p_get_proc_address,
    GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization
) {
    GDExtensionBinding::InitObject init_obj(
        p_get_proc_address,
        p_library,
        r_initialization
    );

    init_obj.register_initializer(initialize_resolution_manager);
    init_obj.register_terminator(uninitialize_resolution_manager);
    init_obj.set_minimum_library_initialization_level(
        MODULE_INITIALIZATION_LEVEL_SCENE
    );

    return init_obj.init();
}
}

#ifndef RESOLUTION_MANAGER_H
#define RESOLUTION_MANAGER_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/array.hpp>

using namespace godot;

class ResolutionManager : public RefCounted {
    GDCLASS(ResolutionManager, RefCounted)

protected:
    static void _bind_methods();

public:
    String get_test_message() const;
    Array get_available_monitors() const;
    int set_resolution(String device_name, int width, int height, int refresh_rate);
    int restore_resolution(String device_name);
    int commit_resolution(String device_name);
};

#endif
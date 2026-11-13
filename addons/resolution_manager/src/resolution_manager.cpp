
#include <windows.h>
#include <string>
#include <map>
#include <vector>

#include "resolution_manager.h"

static std::map<std::wstring, DEVMODEW> original_modes;

static String wide_to_godot_string(const wchar_t *value) {
    int length = WideCharToMultiByte(
        CP_UTF8,
        0,
        value,
        -1,
        nullptr,
        0,
        nullptr,
        nullptr
    );

    if (length <= 1) {
        return String();
    }

    std::vector<char> buffer(length);

    WideCharToMultiByte(
        CP_UTF8,
        0,
        value,
        -1,
        buffer.data(),
        length,
        nullptr,
        nullptr
    );

    return String::utf8(buffer.data());
}

static std::wstring godot_string_to_wide(const String &value) {
    CharString utf8 = value.utf8();

    int length = MultiByteToWideChar(
        CP_UTF8,
        0,
        utf8.get_data(),
        -1,
        nullptr,
        0
    );

    if (length <= 1) {
        return std::wstring();
    }

    std::vector<wchar_t> buffer(length);

    MultiByteToWideChar(
        CP_UTF8,
        0,
        utf8.get_data(),
        -1,
        buffer.data(),
        length
    );

    return std::wstring(buffer.data());
}

static Array get_device_resolutions(const wchar_t *device_name) {
    Array resolutions;

    DEVMODEW mode = {};
    mode.dmSize = sizeof(DEVMODEW);

    for (DWORD i = 0; EnumDisplaySettingsW(device_name, i, &mode); i++) {
        int width = static_cast<int>(mode.dmPelsWidth);
        int height = static_cast<int>(mode.dmPelsHeight);
        int refresh_rate = static_cast<int>(mode.dmDisplayFrequency);

        if (width <= 0 || height <= 0 || refresh_rate <= 0) {
            continue;
        }

        bool already_exists = false;

        for (int j = 0; j < resolutions.size(); j++) {
            Dictionary existing = resolutions[j];

            if (
                static_cast<int>(existing["width"]) == width &&
                static_cast<int>(existing["height"]) == height &&
                static_cast<int>(existing["refresh_rate"]) == refresh_rate
            ) {
                already_exists = true;
                break;
            }
        }

        if (already_exists) {
            continue;
        }

        Dictionary resolution;
        resolution["width"] = width;
        resolution["height"] = height;
        resolution["refresh_rate"] = refresh_rate;

        resolutions.append(resolution);
    }

    return resolutions;
}

void ResolutionManager::_bind_methods() {
    ClassDB::bind_method(
        D_METHOD("get_test_message"),
        &ResolutionManager::get_test_message
    );

    ClassDB::bind_method(
        D_METHOD("get_available_monitors"),
        &ResolutionManager::get_available_monitors
    );

    ClassDB::bind_method(
        D_METHOD("set_resolution", "device_name", "width", "height", "refresh_rate"),
        &ResolutionManager::set_resolution
    );

    ClassDB::bind_method(
        D_METHOD("restore_resolution", "device_name"),
        &ResolutionManager::restore_resolution
    );

    ClassDB::bind_method(
        D_METHOD("commit_resolution", "device_name"),
        &ResolutionManager::commit_resolution
    );

    ClassDB::bind_method(
        D_METHOD("get_device_name_at_position", "x", "y"),
        &ResolutionManager::get_device_name_at_position
    );
}

String ResolutionManager::get_test_message() const {
    return "Resolution Manager extension loaded";
}

Array ResolutionManager::get_available_monitors() const {
    Array monitors;

    for (DWORD i = 0; ; i++) {
        DISPLAY_DEVICEW device = {};
        device.cb = sizeof(DISPLAY_DEVICEW);

        if (!EnumDisplayDevicesW(nullptr, i, &device, 0)) {
            break;
        }

        if (!(device.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)) {
            continue;
        }

        Dictionary monitor;
        monitor["device_name"] = wide_to_godot_string(device.DeviceName);
        monitor["description"] = wide_to_godot_string(device.DeviceString);
        monitor["is_primary"] =
            (device.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) != 0;
        monitor["resolutions"] = get_device_resolutions(device.DeviceName);

        monitors.append(monitor);
    }

    return monitors;
}

String ResolutionManager::get_device_name_at_position(int x, int y) const {
    for (DWORD i = 0; ; i++) {
        DISPLAY_DEVICEW device = {};
        device.cb = sizeof(DISPLAY_DEVICEW);

        if (!EnumDisplayDevicesW(nullptr, i, &device, 0)) {
            break;
        }

        if (!(device.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP)) {
            continue;
        }

        DEVMODEW mode = {};
        mode.dmSize = sizeof(DEVMODEW);

        if (!EnumDisplaySettingsW(
            device.DeviceName,
            ENUM_CURRENT_SETTINGS,
            &mode
        )) {
            continue;
        }

        int left = mode.dmPosition.x;
        int top = mode.dmPosition.y;
        int right = left + static_cast<int>(mode.dmPelsWidth);
        int bottom = top + static_cast<int>(mode.dmPelsHeight);

        if (
            x >= left && x < right &&
            y >= top && y < bottom
        ) {
            return wide_to_godot_string(device.DeviceName);
        }
    }

    return String();
}

int ResolutionManager::set_resolution(
    String device_name,
    int width,
    int height,
    int refresh_rate
) {
    if (width <= 0 || height <= 0 || refresh_rate <= 0) {
        return DISP_CHANGE_BADPARAM;
    }

    std::wstring device = godot_string_to_wide(device_name);

    if (device.empty()) {
        return DISP_CHANGE_BADPARAM;
    }

    DEVMODEW original = {};
    original.dmSize = sizeof(DEVMODEW);

    if (original_modes.find(device) == original_modes.end()) {
        if (!EnumDisplaySettingsW(
            device.c_str(),
            ENUM_CURRENT_SETTINGS,
            &original
        )) {
            return DISP_CHANGE_FAILED;
        }

        original_modes[device] = original;
    }

    DEVMODEW mode = {};
    mode.dmSize = sizeof(DEVMODEW);

    if (!EnumDisplaySettingsW(
        device.c_str(),
        ENUM_CURRENT_SETTINGS,
        &mode
    )) {
        return DISP_CHANGE_FAILED;
    }

    mode.dmPelsWidth = static_cast<DWORD>(width);
    mode.dmPelsHeight = static_cast<DWORD>(height);
    mode.dmDisplayFrequency = static_cast<DWORD>(refresh_rate);
    mode.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY;

    LONG test_result = ChangeDisplaySettingsExW(
        device.c_str(),
        &mode,
        nullptr,
        CDS_TEST | CDS_FULLSCREEN,
        nullptr
    );

    if (test_result != DISP_CHANGE_SUCCESSFUL) {
        return static_cast<int>(test_result);
    }

    LONG result = ChangeDisplaySettingsExW(
        device.c_str(),
        &mode,
        nullptr,
        CDS_FULLSCREEN,
        nullptr
    );

    if (result != DISP_CHANGE_SUCCESSFUL) {
        return static_cast<int>(result);
    }

    return static_cast<int>(result);
}

int ResolutionManager::restore_resolution(String device_name) {
    std::wstring device = godot_string_to_wide(device_name);

    auto it = original_modes.find(device);

    if (it == original_modes.end()) {
        return DISP_CHANGE_BADPARAM;
    }

    LONG result = ChangeDisplaySettingsExW(
        device.c_str(),
        &it->second,
        nullptr,
        CDS_FULLSCREEN,
        nullptr
    );

    if (result == DISP_CHANGE_SUCCESSFUL) {
        original_modes.erase(it);
    }

    return static_cast<int>(result);
}

int ResolutionManager::commit_resolution(String device_name) {
    std::wstring device = godot_string_to_wide(device_name);

    auto it = original_modes.find(device);

    if (it == original_modes.end()) {
        return DISP_CHANGE_BADPARAM;
    }

    return DISP_CHANGE_SUCCESSFUL;
}

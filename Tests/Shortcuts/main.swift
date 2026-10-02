import CoreGraphics
import Foundation

private var gChecks = 0

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    gChecks += 1
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

func hotkey(_ keycode: Int64, modifiers: Int64 = 0, enabled: Bool = true) -> NSDictionary {
    ["enabled": enabled,
     "value": ["type": "standard", "parameters": [65535, keycode, modifiers]]]
}

let functionKeys: [Int64] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109,
                            103, 111, 105, 107, 113, 106, 64, 79, 80, 90]
for (index, keycode) in functionKeys.enumerated() {
    for modifiers: Int64 in [0, 0x800000] {
        loadSpaceSwitchShortcuts(from: ["118": hotkey(keycode, modifiers: modifiers)])
        check(gSpaceKeys[0]?.keycode == keycode, "load F\(index + 1)")
        check(gSpaceKeys[0]?.mods.isEmpty == true, "normalize function flag")
    }
}

loadSpaceSwitchShortcuts(from: [
    "118": hotkey(122, modifiers: 0x800000),
    "119": hotkey(120, modifiers: 0x800000),
    "120": hotkey(99, modifiers: 0x800000),
    "121": hotkey(118, modifiers: 0x800000),
])
for (index, keycode) in functionKeys.prefix(4).enumerated() {
    check(gSpaceKeys[index]?.keycode == keycode, "F1–F4 desktop mapping")
}

loadSpaceSwitchShortcuts(from: [
    "118": hotkey(122, enabled: false),
    "119": hotkey(18),
    "120": hotkey(0),
    "121": hotkey(18, modifiers: 0x40000),
    "122": hotkey(65535, modifiers: 0x40000),
    "79": hotkey(123, enabled: false),
])
check(gSpaceKeys[0] == nil, "disabled F-key stays disabled")
check(gSpaceKeys[1] == nil, "bare number stays unbound")
check(gSpaceKeys[2] == nil, "bare letter stays unbound")
check(gSpaceKeys[3]?.keycode == 18 && gSpaceKeys[3]?.mods == .maskControl,
      "Control+number still works")
check(gSpaceKeys[4] == nil, "cleared shortcut stays unbound")
check(gSpaceKeys[5] == nil, "missing shortcut stays unbound")
check(gBindingLeft == nil, "disabled navigation stays disabled")

loadSpaceSwitchShortcuts(from: nil)
check(gSpaceKeys.allSatisfy { $0 == nil }, "reload clears old desktop bindings")
check(gBindingLeft?.keycode == 123 && gBindingLeft?.mods == .maskControl,
      "missing preferences restore default navigation")

print("Space shortcuts: \(gChecks) checks passed")

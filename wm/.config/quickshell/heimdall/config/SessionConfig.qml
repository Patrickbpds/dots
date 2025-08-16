import Quickshell
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property int dragThreshold: 30
    property bool vimKeybinds: true // Default to true, can be overridden by JSON config
    property Commands commands: Commands {}

    property Sizes sizes: Sizes {}

    component Commands: JsonObject {
        property list<string> logout: ["hyprctl", "dispatch", "exit"]
        property list<string> shutdown: ["systemctl", "poweroff"]
        property list<string> hibernate: ["systemctl", "hibernate"]
        property list<string> reboot: ["systemctl", "reboot"]
    }

    component Sizes: JsonObject {
        property int button: 80
    }
}

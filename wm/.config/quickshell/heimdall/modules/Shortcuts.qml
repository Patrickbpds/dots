import qs.components.misc
import qs.modules.controlcenter
import qs.services
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool launcherInterrupted

    CustomShortcut {
        name: "controlCenter"
        description: "Open control center"
        onPressed: WindowFactory.create()
    }

    CustomShortcut {
        name: "showall"
        description: "Toggle launcher, dashboard and osd"
        onPressed: {
            const v = Visibilities.getForActive();
            if (v) {
                v.launcher = v.dashboard = v.osd = v.utilities = !(v.launcher || v.dashboard || v.osd || v.utilities);
            } else {
                console.error("[Shortcuts] Failed to get visibilities for active monitor");
            }
        }
    }

    CustomShortcut {
        name: "session"
        description: "Toggle session menu"
        onPressed: {
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                visibilities.session = !visibilities.session;
            } else {
                console.error("[Shortcuts] Failed to get visibilities for active monitor");
            }
        }
    }

    CustomShortcut {
        name: "launcher"
        description: "Toggle launcher"
        onPressed: root.launcherInterrupted = false
        onReleased: {
            if (!root.launcherInterrupted) {
                const visibilities = Visibilities.getForActive();
                if (visibilities) {
                    visibilities.launcher = !visibilities.launcher;
                } else {
                    console.error("[Shortcuts] Failed to get visibilities for active monitor - launcher toggle failed");
                }
            }
            root.launcherInterrupted = false;
        }
    }

    CustomShortcut {
        name: "launcherInterrupt"
        description: "Interrupt launcher keybind"
        onPressed: root.launcherInterrupted = true
    }

    IpcHandler {
        target: "drawers"

        function toggle(drawer: string): void {
            if (list().split("\n").includes(drawer)) {
                const visibilities = Visibilities.getForActive();
                if (visibilities) {
                    visibilities[drawer] = !visibilities[drawer];
                } else {
                    console.error(`[IPC] Failed to get visibilities for active monitor - ${drawer} toggle failed`);
                }
            } else {
                console.warn(`[IPC] Drawer "${drawer}" does not exist`);
            }
        }

        function list(): string {
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                return Object.keys(visibilities).filter(k => typeof visibilities[k] === "boolean").join("\n");
            }
            return "";
        }
    }

    IpcHandler {
        target: "controlCenter"

        function open(): void {
            WindowFactory.create();
        }
    }
}
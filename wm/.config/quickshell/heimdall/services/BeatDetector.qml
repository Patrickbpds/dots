pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real bpm: 1

    // Beat detector disabled - binary not available
    // Process {
    //     running: true
    //     command: [Quickshell.env("HEIMDALL_BD_PATH") || "/usr/lib/heimdall/beat_detector", "--no-log", "--no-stats", "--no-visual"]
    //     stdout: SplitParser {
    //         onRead: data => {
    //             const match = data.match(/BPM: ([0-9]+\.[0-9])/);
    //             if (match)
    //                 root.bpm = parseFloat(match[1]);
    //         }
    //     }
    // }
}

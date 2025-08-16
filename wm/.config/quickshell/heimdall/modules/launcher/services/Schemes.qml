pragma Singleton

import ".."
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    function transformSearch(search: string): string {
        return search.slice(`${Config.launcher.actionPrefix}scheme `.length);
    }

    function selector(item: var): string {
        return `${item.name} ${item.flavour} ${item.source || ''}`;
    }

    list: schemes.instances
    useFuzzy: Config.launcher.useFuzzy.schemes
    keys: ["name", "flavour", "source"]
    weights: [0.7, 0.2, 0.1]

    Variants {
        id: schemes

        Scheme {}
    }

    Process {
        id: getSchemes

        running: true
        command: ["heimdall", "scheme", "list", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                const schemeData = JSON.parse(text);
                const list = Object.entries(schemeData).map(([name, schemeInfo]) => {
                    // Check if schemeInfo has a flavours property (new structure)
                    const flavoursObj = schemeInfo.flavours || schemeInfo;
                    return Object.entries(flavoursObj).map(([flavour, colours]) => ({
                        name,
                        flavour,
                        colours,
                        source: schemeInfo.source || 'unknown'
                    }));
                });

                const flat = [];
                for (const s of list)
                    for (const f of s)
                        flat.push(f);

                schemes.model = flat;
            }
        }
    }

    component Scheme: QtObject {
        required property var modelData
        readonly property string name: modelData.name
        readonly property string flavour: modelData.flavour
        readonly property var colours: modelData.colours
        readonly property string source: modelData.source || 'unknown'

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            Quickshell.execDetached(["heimdall", "scheme", "set", "-n", name, "-f", flavour]);
        }
    }
}

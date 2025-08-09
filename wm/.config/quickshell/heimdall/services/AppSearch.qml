pragma Singleton

import qs.modules.common
import "root:/modules/common/functions/fuzzysort.js" as Fuzzy
import "root:/modules/common/functions/levendist.js" as Levendist
import Quickshell
import Quickshell.Io
import QtQuick

/**
 * - Eases fuzzy searching for applications by name
 * - Guesses icon name for window class name  
 * - Dynamically discovers new applications
 */
Singleton {
    id: root
    property bool sloppySearch: Config.options?.search.sloppy ?? false
    property real scoreThreshold: 0.2
    property var dynamicApps: []
    property bool isRefreshing: false
    
    // Timer to debounce rapid refresh requests
    Timer {
        id: refreshDebouncer
        interval: 500
        repeat: false
        onTriggered: actuallyRefresh()
    }
    
    // Process to update desktop database
    Process {
        id: updateDbProcess
        command: ["bash", "-c",
                  `update-desktop-database "${Directories.home}/.local/share/applications" 2>&1 || true`]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    console.log(`update-desktop-database output: ${data}`);
                }
            }
        }
        
        onExited: exitCode => {
            // Always proceed to scan, even if update-desktop-database failed
            console.log(`Desktop database update completed (exit code: ${exitCode})`);
            desktopScanner.running = true;
        }
    }
    
    // Process to scan for desktop files
    Process {
        id: desktopScanner
        property string scanCommand: `find /usr/share/applications ${Directories.home}/.local/share/applications -name '*.desktop' -type f 2>/dev/null | head -200`
        
        command: ["bash", "-c", scanCommand]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    const files = data.trim().split('\n').filter(f => f.length > 0);
                    console.log(`Desktop scanner found ${files.length} desktop files`);
                    if (files.length > 0) {
                        console.log(`First 5 files: ${files.slice(0, 5).join(', ')}`);
                    }
                    parseDesktopFileList(files);
                }
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    console.log(`Desktop scanner stderr: ${data}`);
                }
            }
        }
        
        onExited: exitCode => {
            console.log(`Desktop scanner exited with code: ${exitCode}`);
            console.log(`Dynamic app scan complete: ${dynamicApps.length} apps found`);
            
            // Log first few apps for debugging
            if (dynamicApps.length > 0) {
                console.log("First 3 dynamic apps:");
                dynamicApps.slice(0, 3).forEach(app => {
                    console.log(`  - ${app.name} (${app.id})`);
                });
            }
            
            // Log sample of existing apps for comparison
            const existingApps = Array.from(DesktopEntries.applications.values);
            console.log(`Total apps available: ${existingApps.length} (built-in) + ${dynamicApps.length} (dynamic)`);
            
            isRefreshing = false;
        }
        
        onRunningChanged: {
            if (running) {
                console.log(`Starting desktop scan with command: ${scanCommand}`);
            }
        }
    }
    
    // Process to parse individual desktop files
    Process {
        id: desktopParser
        property var pendingFiles: []
        property var parsedApps: []
        property string currentFile: ""
        property int totalToProcess: 0
        
        command: ["bash", "-c", ""]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    const app = parseDesktopContent(data, desktopParser.currentFile);
                    if (app) {
                        desktopParser.parsedApps.push(app);
                        console.log(`  ✓ Parsed: ${app.name} (ID: ${app.id})`);
                    }
                }
            }
        }
        
        stderr: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    console.log(`Parser stderr for ${desktopParser.currentFile}: ${data}`);
                }
            }
        }
        
        onExited: exitCode => {
            const remaining = desktopParser.pendingFiles.length;
            if (remaining > 0) {
                console.log(`  Parsing progress: ${totalToProcess - remaining}/${totalToProcess}`);
                parseNextFile();
            } else {
                // All files parsed, update dynamic apps
                console.log(`\n=== Parsing complete ===`);
                console.log(`Successfully parsed ${desktopParser.parsedApps.length} new apps`);
                
                if (desktopParser.parsedApps.length > 0) {
                    console.log("New apps discovered:");
                    desktopParser.parsedApps.forEach(app => {
                        console.log(`  • ${app.name} (${app.id})`);
                    });
                }
                
                dynamicApps = desktopParser.parsedApps;
                desktopParser.parsedApps = [];
                desktopParser.totalToProcess = 0;
            }
        }
        
        function parseNextFile() {
            if (pendingFiles.length === 0) return;
            
            const file = pendingFiles.shift();
            currentFile = file;
            // Extract Name (including localized), Exec, Icon, and NoDisplay fields
            // Look for Name= or Name[anything]= patterns
            command = ["bash", "-c", 
                      `grep -E '^(Name(\\[.*\\])?=|Exec=|Icon=|NoDisplay=)' "${file}" 2>/dev/null | head -10`];
            running = false;
            running = true;
        }
    }
    
    function parseDesktopFileList(files) {
        console.log(`\n=== Desktop File Analysis ===`);
        console.log(`Total desktop files found: ${files.length}`);
        
        // Get IDs that are already in DesktopEntries (these work fine)
        const existingIds = new Set(
            Array.from(DesktopEntries.applications.values)
                .map(e => e.id)
        );
        
        console.log(`Apps already in DesktopEntries: ${existingIds.size}`);
        
        // Log some existing IDs for debugging
        const sampleIds = Array.from(existingIds).slice(0, 5);
        console.log(`Sample existing IDs: ${sampleIds.join(', ')}`);
        
        // Parse ALL files, not just new ones
        // We'll deduplicate later in fuzzyQuery
        // This ensures we catch newly installed apps
        const filesToParse = files.filter(file => {
            // Skip files that are already in DesktopEntries by checking the ID
            const filename = file.split('/').pop().replace('.desktop', '');
            const alreadyExists = existingIds.has(filename) || 
                                 existingIds.has(filename.replace(/-/g, '_')) ||
                                 existingIds.has('org.kde.' + filename) ||
                                 existingIds.has('org.gnome.' + filename);
            
            return !alreadyExists;
        });
        
        console.log(`New files to parse: ${filesToParse.length}`);
        
        if (filesToParse.length > 0) {
            console.log(`\nStarting to parse ${filesToParse.length} new desktop files...`);
            if (filesToParse.length <= 10) {
                // If few files, log them all
                filesToParse.forEach(f => console.log(`  - ${f}`));
            } else {
                // If many files, just log first few
                console.log("First 5 files to parse:");
                filesToParse.slice(0, 5).forEach(f => console.log(`  - ${f}`));
                console.log(`  ... and ${filesToParse.length - 5} more`);
            }
            
            desktopParser.pendingFiles = filesToParse;
            desktopParser.parsedApps = [];
            desktopParser.totalToProcess = filesToParse.length;
            desktopParser.parseNextFile();
        } else {
            console.log("No new desktop files to parse - all apps are already in DesktopEntries");
            dynamicApps = [];
            isRefreshing = false;
        }
    }
    
    function parseDesktopContent(content, filepath) {
        const lines = content.split('\n');
        let name = "", exec = "", icon = "", noDisplay = false;
        
        for (const line of lines) {
            // Prefer non-localized name, but accept localized if that's all we have
            if (line.startsWith("Name=")) {
                name = line.substring(5);
            } else if (line.startsWith("Name[") && !name) {
                // Extract localized name if we don't have a generic one
                const match = line.match(/^Name\[.*\]=(.+)$/);
                if (match) name = match[1];
            } else if (line.startsWith("Exec=")) {
                exec = line.substring(5);
            } else if (line.startsWith("Icon=")) {
                icon = line.substring(5);
            } else if (line.startsWith("NoDisplay=true")) {
                noDisplay = true;
            }
        }
        
        // Skip hidden apps or those without required fields
        if (noDisplay || !name || !exec) {
            console.log(`Skipping ${filepath}: NoDisplay=${noDisplay}, name="${name}", exec="${exec}"`);
            return null;
        }
        
        // Clean exec command (remove %f %U etc)
        exec = exec.replace(/%[fFuUdDnNickvm]/g, '').trim();
        
        // Generate ID from filename
        const filename = filepath.split('/').pop().replace('.desktop', '');
        
        return {
            name: name,
            icon: icon || "application-x-executable",
            id: filename,
            execute: () => {
                Quickshell.execDetached(["bash", "-c", exec]);
            }
        };
    }
    
    function refreshAppList() {
        if (isRefreshing) {
            console.log("Refresh already in progress, skipping");
            return;
        }
        console.log("Scheduling app list refresh...");
        refreshDebouncer.restart();
    }
    
    function actuallyRefresh() {
        isRefreshing = true;
        console.log("Starting actual refresh of application list...");
        console.log(`Current DesktopEntries count: ${Array.from(DesktopEntries.applications.values).length}`);
        console.log(`Current dynamic apps count: ${dynamicApps.length}`);
        updateDbProcess.running = false;
        updateDbProcess.running = true;
    }
    property var substitutions: ({
        "code-url-handler": "visual-studio-code",
        "Code": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "wps": "wps-office2019-kprometheus",
        "wpsoffice": "wps-office2019-kprometheus",
        "footclient": "foot",
        "zen": "zen-browser",
        "brave-browser": "brave-desktop"
    })
    property var regexSubstitutions: [
        {
            "regex": /^steam_app_(\d+)$/,
            "replace": "steam_icon_$1"
        },
        {
            "regex": /Minecraft.*/,
            "replace": "minecraft"
        },
        {
            "regex": /.*polkit.*/,
            "replace": "system-lock-screen"
        },
        {
            "regex": /gcr.prompter/,
            "replace": "system-lock-screen"
        }
    ]

    readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var preppedNames: list.map(a => ({
        name: Fuzzy.prepare(`${a.name} `),
        entry: a
    }))

    readonly property var preppedIcons: list.map(a => ({
        name: Fuzzy.prepare(`${a.icon} `),
        entry: a
    }))

    function fuzzyQuery(search: string): var { // Idk why list<DesktopEntry> doesn't work
        // Combine results from both DesktopEntries and dynamic apps
        let results = [];
        
        if (root.sloppySearch) {
            // Search in original list
            const baseResults = list.map(obj => ({
                entry: obj,
                score: Levendist.computeScore(obj.name.toLowerCase(), search.toLowerCase())
            })).filter(item => item.score > root.scoreThreshold);
            
            // Search in dynamic apps
            const dynamicResults = dynamicApps.map(obj => ({
                entry: obj,
                score: Levendist.computeScore(obj.name.toLowerCase(), search.toLowerCase())
            })).filter(item => item.score > root.scoreThreshold);
            
            // Combine and sort
            results = [...baseResults, ...dynamicResults]
                .sort((a, b) => b.score - a.score)
                .map(item => item.entry);
        } else {
            // Fuzzy search in original list
            const baseResults = Fuzzy.go(search, preppedNames, {
                all: true,
                key: "name"
            }).map(r => r.obj.entry);
            
            // Fuzzy search in dynamic apps
            const preppedDynamic = dynamicApps.map(a => ({
                name: Fuzzy.prepare(`${a.name} `),
                entry: a
            }));
            
            const dynamicResults = Fuzzy.go(search, preppedDynamic, {
                all: true,
                key: "name"
            }).map(r => r.obj.entry);
            
            // Combine results, dynamic apps first (they're newer)
            results = [...dynamicResults, ...baseResults];
        }
        
        // Remove duplicates by name
        const seen = new Set();
        return results.filter(app => {
            const key = app.name.toLowerCase();
            if (seen.has(key)) return false;
            seen.add(key);
            return true;
        });
    }

    function iconExists(iconName) {
        if (!iconName || iconName.length == 0) return false;
        return (Quickshell.iconPath(iconName, true).length > 0) 
            && !iconName.includes("image-missing");
    }

    function getReverseDomainNameAppName(str) {
        return str.split('.').slice(-1)[0]
    }

    function getKebabNormalizedAppName(str) {
        return str.toLowerCase().replace(/\s+/g, "-");
    }

    function guessIcon(str) {
        if (!str || str.length == 0) return "image-missing";

        // Normal substitutions
        if (substitutions[str]) return substitutions[str];
        if (substitutions[str.toLowerCase()]) return substitutions[str.toLowerCase()];

        // Regex substitutions
        for (let i = 0; i < regexSubstitutions.length; i++) {
            const substitution = regexSubstitutions[i];
            const replacedName = str.replace(
                substitution.regex,
                substitution.replace,
            );
            if (replacedName != str) return replacedName;
        }

        // Icon exists -> return as is
        if (iconExists(str)) return str;


        // Simple guesses
        const lowercased = str.toLowerCase();
        if (iconExists(lowercased)) return lowercased;

        const reverseDomainNameAppName = getReverseDomainNameAppName(str);
        if (iconExists(reverseDomainNameAppName)) return reverseDomainNameAppName;

        const lowercasedDomainNameAppName = reverseDomainNameAppName.toLowerCase();
        if (iconExists(lowercasedDomainNameAppName)) return lowercasedDomainNameAppName;

        const kebabNormalizedGuess = getKebabNormalizedAppName(str);
        if (iconExists(kebabNormalizedGuess)) return kebabNormalizedGuess;


        // Search in desktop entries
        const iconSearchResults = Fuzzy.go(str, preppedIcons, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry
        });
        if (iconSearchResults.length > 0) {
            const guess = iconSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }

        const nameSearchResults = root.fuzzyQuery(str);
        if (nameSearchResults.length > 0) {
            const guess = nameSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }


        // Give up
        return str;
    }
}

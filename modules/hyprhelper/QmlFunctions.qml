import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Item {
    //TODO: put Hyprland.refreshToplevels in places here
    //also put Hyprland.refreshWorkspaces
    id: root

    Process {
        id: shellGetToplevel
        property string output: ""
        stdout: StdioCollector {
            onStreamFinished: shellGetToplevel.output = this.text
        }
    }

    function iterate(model, callback) {
        var rv = null;
        model.values.forEach(item => {
            var returnValue = callback(item);
            if (returnValue) {
                rv = returnValue;
                return returnValue;
            }
        });
        return rv;
    }

    function iterateToplevels(callback) {
        return iterate(Hyprland.toplevels, callback);
    }

    function iterateWorkspaces(callback) {
        return iterate(Hyprland.workspaces, callback);
    }

    function get(model, index: string, value) {
        return iterate(model, item => {
            if (item[index] === value) {
                return item;
            }
        });
    }

    function getToplevel(index: string, value): HyprlandToplevel {
        console.log("getting toplevel:", index, value);
        //returns the first toplevel where toplevel[index] matches value
        //size is manually defined because quickshell doesn't track it
        if (index === "size") {
            iterateToplevels(toplevel => {
                const tlSize = root.topLevelSizes[toplevel.address];
                if (tlSize === value) {
                    return toplevel;
                }
            });
            return;
        }
        const rv = get(Hyprland.toplevels, index, value);
        console.log("get toplevel found:", rv);
        return rv;
    }

    function getWorkspace(index: string, value): HyprlandWorkspace {
        //returns the first workspace where workspace[index] matches value
        return get(Hyprland.workspaces, index, value);
    }

    function getv2(model, attributes, value) {
        var returnValue = null;
        for (const attribute of attributes) {
            returnValue = get(model, attribute, value);
            if (returnValue) {
                break;
            }
        }
        return returnValue;
    }

    function getToplevelv2(value): HyprlandToplevel {
        //smart adaptation of GetToplevel
        const attributes = ["address", "title", "handle"];
        return getv2(Hyprland.toplevels, attributes, value);
    }

    function getWorkspacev2(value): HyprlandWorkspace {
        //smart adaptation of GetWorkspace
        const attributes = ["id", "name"];
        return getv2(Hyprland.workspaces, attributes, value);
    }

    function getToplevelsInWorkspace(workspace): Array<HyprlandToplevel> {
        const em = "Invalid argument ${workspace} to GetToplevelsInWorkspace";
        if (typeof workspace === "number" || typeof workspace === "string") {
            workspace = getWorkspacev2(workspace);
        }
        if (!workspace) {
            console.error(em);
        }
        const toplevels = workspace.toplevels;
        if (!toplevels) {
            console.warn("No toplevels found in workspace ${workspace}. This isn't an issue unless the argument was invalid");
        }
        return toplevels;
    }

    function getToplevelWorkspace(toplevel): HyprlandWorkspace {
        const em = "Invalid argument ${toplevel} to GetToplevelWorkspace";
        if (typeof toplevel === "string") {
            toplevel = getToplevelv2(toplevel);
        }
        if (!toplevel) {
            console.error(em);
        }
        const workspace = tl.workspace;
        if (!workspace) {
            console.error(em);
        }
    }

    function getWorkspaceMaster(workspace): HyprlandToplevel {
        //TODO: test functionality of area getter process
        if (typeof workspace === "string" || typeof workspace === "number") {
            workspace = getWorkspacev2(workspace);
        }
        if (!workspace) {
            console.error("Invalid argument", workspace, "passed to GetWorkspaceMaster\n");
        }
        var largestToplevel = null;
        var largestToplevelArea = 0;
        iterate(workspace.toplevels, toplevel => {
            shellGetToplevel.exec({
                command: ["bash", "-c", "~/.config/quickshell/taskbar/modules/hyprhelper/GetWindow.sh " + toplevel.address + " size"]
            });
            const size = shellGetToplevel.output;
            const area = size[0] * size[1];
            if (area > largestToplevelArea) {
                largestToplevel = toplevel;
                largestToplevelArea = area;
            }
        });
        return largestToplevel;
    }
}

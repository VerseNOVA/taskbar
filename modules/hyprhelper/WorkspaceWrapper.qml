import Quickshell
import QtQuick
import Quickshell.Hyprland

import "./QmlFunctions.qml"

Item {
    id: root

    property var workspace: null

    property var masterToplevel: null
    //TODO: debug masterToplevel initializing poorly

    readonly property int id: workspace ? workspace.id : -1
    readonly property string name: workspace ? workspace.name : ""
    readonly property bool active: workspace ? workspace.active : false
    readonly property bool focused: workspace ? workspace.focused : false
    readonly property bool hasFullscreen: workspace ? workspace.hasFullscreen : false
    readonly property var monitor: workspace ? workspace.monitor : null
    readonly property var toplevels: workspace ? workspace.toplevels : null

    function findMasterWindow() {
        console.log("workspaceWrapper " + id + " searching for master window");
        if (!toplevels || toplevels.count === 0) {
            masterToplevel = null;
            return;
        }

        var maxArea = 0;
        var masterCandidate = null;
        for (var i = 0; i < toplevels.values.length; i++) {
            var window = toplevels.values[i];
            console.log("checking window " + window);

            if (window.minimized) {
                continue;
              }
              console.log("getting toplevel size from WorkspaceWrapper of window "+window)
            const lastipc = window.lastIpcObject
            console.log(lastipc)
            const size = QmlFunctions.getToplevelSize(window)
            console.log("toplevel has size of "+size, size[0], size[1])
            var area = size[0] * size[1];
            console.log("Window", window.title, "area:", area);

            if (area > maxArea) {
                maxArea = area;
                masterCandidate = window;
            }
        }

        masterToplevel = masterCandidate;
        console.log("Master window selected:", masterToplevel?.title, "with area:", maxArea);
        return masterToplevel;
    }

    onToplevelsChanged: {
        findMasterWindow();
    }

    function activateWithLog() {
        console.log("Activating workspace:", name, "with master:", masterToplevel?.title);
        if (workspace) {
            workspace.activate();
        }
    }

    Component.onCompleted: {
        findMasterWindow();
        console.log("WorkspaceWrapper created for:", id, name);
    }
}

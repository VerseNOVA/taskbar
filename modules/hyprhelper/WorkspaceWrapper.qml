import Quickshell
import QtQuick
import Quickshell.Hyprland

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
      Hyprland.refreshToplevels()
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
            const size = window.lastIpcObject.size
            var area = size[0] * size[1];

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

import Quickshell
import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var workspace: null

    property var masterToplevel: null

    readonly property int workspaceId: workspace ? workspace.id : -1
    readonly property string workspaceName: workspace ? workspace.name : ""
    readonly property bool active: workspace ? workspace.active : false
    readonly property bool focused: workspace ? workspace.focused : false
    readonly property bool hasFullscreen: workspace ? workspace.hasFullscreen : false
    readonly property var monitor: workspace ? workspace.monitor : null
    readonly property var toplevels: workspace ? workspace.toplevels : null

    function findMasterWindow() {
        if (!toplevels || toplevels.count === 0) {
            masterToplevel = null;
            return;
        }

        var maxArea = 0;
        var masterCandidate = null;

        for (var i = 0; i < toplevels.count; i++) {
            var window = toplevels.get(i);

            if (window.minimized)
                continue;
            var area = window.windowArea;
            console.log("Window", window.title, "area:", area);

            if (area > maxArea) {
                maxArea = area;
                masterCandidate = window;
            }
        }

        masterToplevel = masterCandidate;
        console.log("Master window selected:", masterToplevel?.title, "with area:", maxArea);
    }

    onToplevelsChanged: {
        findMasterWindow();
    }

    function activateWithLog() {
        console.log("Activating workspace:", workspaceName, "with master:", masterToplevel?.title);
        if (workspace) {
            workspace.activate();
        }
    }

    Component.onCompleted: {
        findMasterWindow();
        console.log("WorkspaceWrapper created for:", workspaceName);
    }
}

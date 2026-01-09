import QtQuick
import Quickshell.Hyprland

import "./QmlFunctions.qml"

Item {
    id: root

    property HyprlandToplevel toplevel: null

    readonly property string title: toplevel ? toplevel.title : ""
    readonly property string address: toplevel ? toplevel.address : ""
    readonly property bool activated: toplevel ? toplevel.activated : false
    readonly property bool urgent: toplevel ? toplevel.urgent : false
    readonly property bool minimized: toplevel ? toplevel.minimized : false
    readonly property HyprlandWorkspace workspace: toplevel ? toplevel.workspace : null
    readonly property HyprlandMonitor monitor: toplevel ? toplevel.monitor : null
    readonly property var wayland: toplevel ? toplevel.wayland : null

    readonly property string shortTitle: title.length > 30 ? title.substring(0, 27) + "..." : title
    readonly property string displayName: title || "Untitled Window"
    readonly property bool isMaster: false // Will be set by workspace wrapper

    readonly property real windowSize: toplevel ? QmlFunctions.getToplevelSize(toplevel) : 0

    readonly property real windowArea: {
        const size = QmlFunctions.getToplevelSize(toplevel);
        return size[0] * size[1];
        //TODO: rewrite to use the QmlFunctions bash process that gets it from hyprctl rather than some xdg shit
        if (!wayland || !wayland.xdgSurface || !wayland.xdgSurface.maxSize)
            return 0;
        var scale = monitor ? monitor.scale : 1.0;
        var w = wayland.xdgSurface.maxSize.width * scale;
        var h = wayland.xdgSurface.maxSize.height * scale;
        return w * h;
    }

    readonly property string areaString: {
        if (windowArea === 0)
            return "Unknown";
        if (windowArea < 1000000)
            return Math.round(windowArea) + " px²";
        return (windowArea / 1000000).toFixed(2) + "M px²";
    }

    function focusWindow() {
        if (workspace) {
            workspace.activate();
        }
    }

    readonly property string stateString: {
        if (minimized)
            return "Minimized";
        if (activated)
            return "Active";
        if (urgent)
            return "Urgent";
        return "Normal";
    }
}

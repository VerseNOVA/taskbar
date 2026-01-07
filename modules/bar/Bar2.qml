pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

import "../hyprhelper/"
import "../hyprhelper/WorkspaceWrapper.qml"

Scope {
    id: root

    property color c1: "#151515"
    property color c2: "#222222"

    property WorkspaceWrapper workspaceWrapper: WorkspaceWrapper {}

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            implicitHeight: 45
            anchors.top: true
            anchors.left: true
            anchors.right: true
            required property var modelData
            color: "gray"

            Rectangle {
                anchors.fill: parent
                gradient: root.barGradient
              }
            Text {
                anchors.fill: parent
                color: "red"
                text: workspaceWrapper.focusedWorkspace.id
            }
            Text {
                anchors.fill: parent
                color: "green"
                //text: workspaceWrapper.focusedWorkspaceMaster.address
                text: "testing green"
            }
        }
    }

    property Gradient barGradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.0
            color: root.c1
        }
        GradientStop {
            position: 0.1
            color: root.c2
        }
        GradientStop {
            position: 0.9
            color: root.c2
        }
        GradientStop {
            position: 1.0
            color: root.c1
        }
    }
}

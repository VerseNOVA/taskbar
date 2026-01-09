pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

import "../hyprhelper"

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
              color: "red"
              font.pointSize:24
                text: HyprWrapper.focusedWorkspace.id
            }
            Text {
                x: 30
                y: 0
                height: 240
                width: 200
                font.pointSize:24
                color: "green"
                text: HyprWrapper.focusedWorkspace.masterToplevel.address
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

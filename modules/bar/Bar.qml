import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

import "../hyprhelper/"

//import "../widgets/WorkspaceIcon" as WorkspaceIcon

Scope {
    id: root

    property Gradient barGradient
    property color c1: "#151515"
    property color c2: "#222222"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            anchors.top: true
            anchors.left: true
            anchors.right: true

            margins.left: 0
            margins.right: 0

            Rectangle {
                property color c1: "#151515"
                property color c2: "#222222"

                implicitHeight: 60
                anchors.fill: parent
                gradient: root.barGradient
            }
            Text {
                id: testText
                text: "test"
                anchors.centerIn: parent
                color: "#FFFFFF"
            }
            Text {
                id: test2Text
                //text: WorkspaceIcon.WindowInformation.activeWorkspace.id
                text: WorkspaceWrapper.focusedWorkspace.id
                color: "#FF0000"
            }
            Process {
                running: true
                command: ["bash", "-c", "~/.config/quickshell/taskbar/modules/hyprhelper/GetMasterWindow.sh -a address"]
                stdout: StdioCollector {
                    onStreamFinished: testText.text = this.text
                }
            }
        }
    }
    barGradient: Gradient {
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

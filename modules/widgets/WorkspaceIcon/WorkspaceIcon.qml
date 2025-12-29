import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Scope {
    Variants {
        model: Hyprland.workspaces
        AbstractButton {
            id: button

            required property var modelData
            property var workspace: this.modelData

            checkable: false
            display: IconOnly
            
            icon: {
                source: "";
                name: "";
              }
            }
        Process {
            command: {"bash", "./GetMasterWindow.sh"}
            stdout: StdioCollector {
                onStreamFinished: button.icon.name = this.text
            }
        }
    }
}

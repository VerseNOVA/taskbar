//@ pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar" as Bar
import "./modules/hyprhelper/" as Hyprhelper

ShellRoot {
    id: root
    Loader {
        active: true
        Bar.Bar {}
        Hyprhelper.WorkspaceWrapper {}
    }
}

//TODO: make Bar.qml load the WindowInformation singleton to test it

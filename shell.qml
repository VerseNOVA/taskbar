//@ pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar" as Bar
import "./modules/hyprhelper/" as Hyprhelper

ShellRoot {
    id: root
    Loader {
        active: true
        Item {
          property var hyprWrapper: Hyprhelper.HyprWrapper
          Component.onCompleted: {
            hyprWrapper.initialize()
          }
        }
        Bar.Bar2 {}
    }
}

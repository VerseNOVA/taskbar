pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Hyprland

Singleton {
  property var workspaceWrappers: []
  property WorkspaceWrapper focusedWorkspace: null

  property component workspaceWrapperTemplate: Qt.createComponent(WorkspaceWrapper)

  function addWorkspaceWrapper(workspace: HyprlandWorkspace) {
    if (!workspace) {
      console.error("no workspace passed to addWorkspaceWrapper")
    }
    var newWrapper = workspaceWrapperTemplate.createObject(null, {
      "workspace": workspace
    })
    workspaceWrappers.push(newWrapper)
  }

  function initialize() {
    QmlFunctions.iterate(Hyprland.Workspaces, workspace => {
      addWorkspaceWrapper(workspace)
    })
  }

  Connections {
    target: Hyprland
    function onRawEvent(event: HyprlandEvent) {
      switch (event.name) {
        case "createworkspacev2":
          data = event.parse(2)
          workspaceId = data[0]
          workspaceObject = QmlFunctions.getWorkspace("id", workspaceId)
          addWorkspaceWrapper(workspaceObject)
        case "removeworkspacev2":
          data = event.parse(2)
          workspaceId = data[0]
          for (const workspaceWrapper of workspaceWrappers) {
            if (workspaceWrapper.workspaceId === workspaceId) {
              const index = workspaceWrappers.indexOf(workspaceWrapper)
              if (index <= -1) {
                continue
              }
              array.splice(index, 1)
              break
            }
          }
      }
    }
  }
}

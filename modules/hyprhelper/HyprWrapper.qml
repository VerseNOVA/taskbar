pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Hyprland

Singleton {
    property Hyprland hyprland: Hyprland

    property var workspaceWrappers: {
        var wrappers = [];
        Hyprland.workspaces.values.forEach(workspace => {
            console.log("initializing workspaceWrapper for existing workspace " + workspace.id);
            const newWrapper = workspaceWrapperTemplate.createObject(null, {
                "workspace": workspace
            });
            wrappers.push(newWrapper);
        });
        return wrappers;
    }

    property WorkspaceWrapper focusedWorkspace: {
        var ret = null;
        workspaceWrappers.forEach(workspaceWrapper => {
            if (workspaceWrapper.id === Hyprland.focusedWorkspace.id) {
                ret = workspaceWrapper;
            }
        });
        if (ret) {
            console.log("initial focused workspace set to id " + ret.id + " (name " + ret.name + ")");
        } else {
            console.warn("no initial workspace found");
        }
        return ret;
    }

    property Component workspaceWrapperTemplate: Qt.createComponent("WorkspaceWrapper.qml")

    function addWorkspaceWrapper(workspace: HyprlandWorkspace) {
        if (!workspace) {
            console.error("no workspace passed to addWorkspaceWrapper");
        }
        var newWrapper = workspaceWrapperTemplate.createObject(null, {
            "workspace": workspace
        });
        workspaceWrappers.push(newWrapper);
    }

    function initialize() {
        return;
        //TODO: get initialization to set all variables faster or smth
        //when i use the singleton in other scripts it isnt initialized fast enough
        Hyprland.workspaces.values.forEach(workspace => {
            addWorkspaceWrapper(workspace);
        });
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent) {
            switch (event.name) {
            case "createworkspacev2":
                {
                    const data = event.parse(2);
                    const workspaceId = data[0];
                    const workspaceObject = QmlFunctions.getWorkspace("id", workspaceId);
                    addWorkspaceWrapper(workspaceObject);
                }
            case "removeworkspacev2":
                {
                    const data = event.parse(2);
                    const workspaceId = data[0];
                    for (const workspaceWrapper of workspaceWrappers) {
                        if (workspaceWrapper.workspaceId === workspaceId) {
                            const index = workspaceWrappers.indexOf(workspaceWrapper);
                            if (index <= -1) {
                                continue;
                            }
                            array.splice(index, 1);
                            break;
                        }
                    }
                }
            case "workspacev2":
                {
                    const data = event.parse(2);
                    const workspaceId = data[0];
                    for (const workspaceWrapper of workspaceWrappers) {
                        if (workspaceWrapper.workspaceId === workspaceId) {
                            focusedWorkspace = workspaceWrapper;
                            break;
                        }
                    }
                }
            //TODO: add case to change focus based on whether special is active or inactive
            }
        }
    }
}

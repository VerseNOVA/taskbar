import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import qs.modules.hyprhelper

//TODO: rewrite this to use QmlFunctions.Qml
//it really just uses js functions but it can access hyprland more directly
Scope {
    id: root
    property var masterWindows: ({})
    property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace

    Variants {
        model: Hyprland.workspaces

        Item {
            required property HyprlandWorkspace modelData
            property HyprlandWorkspace workspace: modelData
            property string largestWindowAddress: root.masterWindows[workspace.id]
            property bool active: Hyprland.focusedWorkspace === workspace
            //TODO: check if the above property is reactive
            //if not then find a way for it to be
        }
      }
    Process {
      id: writeWindowCache
      property string output: ""
      running: false
        stdout: StdioCollector {
            onStreamFinished: writeWindowCache.output = this.text
        }
    }
    Process {
      id: writeWorkspaceCache
      property string output: ""
        running: false
        stdout: StdioCollector {
          onStreamFinished: writeWorkspaceCache.output = this.text   
        }
      }

    QmlFunctions {
      id: functions
    }

    function updateWorkspaceMaster(workspaceId) {
      const master = functions.getWorkspaceMaster(workspaceId)
      masterWindows[workspaceId] = master
    }
    function updateWorkspaceMasterWindow(workspaceId: int) {
      updateWorkspaceMaster(workspaceId)
      return
      //below is archived
        writeWindowCache.exec({
            command: ["bash", "-c", "~/.config/quickshell/taskbar/modules/hyprhelper/GetMasterWindow.sh -a address -w" + workspaceId]
          });
        console.log("Updating master window of workspace "+workspaceId+" to "+writeWindowCache.output+" (call from "+callfrom+")")
        masterWindows[workspaceId] = writeWindowCache.output;
    //TODO: possibly check if this window is anywhere else there and update those windows TODO
    //we will need to see if there is a bug to fix and see if that fixes it
    //TODO: fix bug where it takes instantiating 3 windows in a workspace to get it set up to take more windows
    //has something to do with the bash process scripts
    //I feel like it is because the workspaceid is delayed by 1 window, so it doesnt go properly
    //the cache and function only return the previous value, not the current one
    }
    function isMasterWindow(windowAddress: string): int {
        //returns workspace id (0 of there is no workspace)
        //if the window is not a master window, then it will return 0
        for (var i = 0; i < masterWindows.count; i++) {
            var element = masterWindows.get(i);
            if (element == windowAddress) {
                return i;
            }
        }
        return 0;
      }

      function isMasterWindowObj(window: HyprlandToplevel): int {
        isMasterWindow(window.address)
        //can rewrite above to be more efficient
    }

    Connections {
      target: Hyprland

      function onRawEvent(event: HyprlandEvent) {
        if (event.name === "openwindow") {
          const data = event.parse(4) //0=address;1=workspacename;2=windowclass;4=windowtitle
          const address = data[0]
          const toplevel = functions.getToplevel("address", address)
          const workspaceid = toplevel.workspace.id
          updateWorkspaceMaster(workspaceid)
        } else if (event.name === "closewindow") {
          console.log("workspacewrapper detected closing window; will likel error")
          const data = event.parse(1) //0=windowaddress
          const address = data[0]
          const toplevel = functions.getToplevel("address", address)
          const workspaceid = toplevel.workspace.id
          if (!workspaceid) {
            console.warn("no worksace id found for "+toplevel.address+" in closewindow")
            return
          }
          updateWorkspaceMaster(workspaceid)
        } else if (event.name === "movewindowv2") {
          const data = event.parse(3) //0=windowaddress;1=workspaceid;2=workspacename
          const workspaceid = data[1]
          updateWorkspaceMaster(workspaceid)
        } else if (event.name === "changefloatingmode") {
          const data = event.parse(2) //1=windowaddress;2=floating(0/1)
          const address = data[0]
          const toplevel = functions.getToplevel("address", address)
          const workspaceid = toplevel.workspace.id
          updateWorkspaceMaster(workspaceid)
        }
        //may want to just use Hyprland.toplevels.changed
        //rawevent doesnt have a lot of important events
      }
    }
  }

  //TODO: probably need to save a list of all toplevel addresses and their window for the closewindow
  //function
  //TODO: make the functions below in a seperate module if possible

// SPDX-FileCopyrightText: James Eversole <james@eversole.co>
// SPDX-License-Identifier: ISC
// Modified 2026-10-08 (personal_workplace): re-check the voxtype daemon on every
// poll so the icon recovers if voxtype starts after plasmashell or restarts.

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Panel size — small icon size for system tray / panel
    Layout.preferredWidth: Kirigami.Units.iconSizes.small
    Layout.preferredHeight: Kirigami.Units.iconSizes.small

    // Tooltip
    Plasmoid.title: "Voxtype Toggle"
    toolTipSubText: statusText

    // State tracking
    property string currentState: "idle"
    property string statusText: "Voxtype is idle"

    // State file paths (same as voxtype GNOME extension)
    readonly property string runtimeDir: "/run/user/1000"
    readonly property string stateFilePath: runtimeDir + "/voxtype/state"
    readonly property string pidFilePath: runtimeDir + "/voxtype/pid"

    // Data source for executing voxtype record toggle
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        function toggleRecording() {
            if (daemonRunning) {
                executable.connectSource("voxtype record toggle")
            } else {
                updateState("not-running")
            }
        }

        function checkDaemon() {
            // Check if the voxtype daemon process is running
            var cmd = "if [ -f " + root.pidFilePath + " ]; then kill -0 $(cat " + root.pidFilePath + ") 2>/dev/null && echo running; fi"
            executable.connectSource(cmd)
        }

        onNewData: function(sourceName, data) {
            var exitCode = data["exit code"]
            var output = data.stdout.trim()

            // Handle the toggle command
            if (sourceName.includes("voxtype record toggle")) {
                executable.disconnectSource(sourceName)
                // Re-read state from disk after toggling
                refreshState()
                return
            }

            // Handle daemon check
            if (sourceName.includes("kill -0")) {
                executable.disconnectSource(sourceName)
                daemonRunning = output === "running"
                if (!daemonRunning) {
                    updateState("not-running")
                } else if (currentState === "not-running") {
                    // daemon came (back) up: leave the warning state
                    refreshState()
                }
            }
        }
    }

    // Data source for reading the state file from disk
    Plasma5Support.DataSource {
        id: stateReader
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            stateReader.disconnectSource(sourceName)
            var output = data.stdout.trim()
            // If the state file doesn't exist or is empty, default to idle
            updateState(output || "idle")
        }
    }

    // Periodic timer: re-check the daemon and refresh state from disk
    Timer {
        id: stateRefreshTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            executable.checkDaemon()
            if (daemonRunning) {
                refreshState()
            }
        }
    }

    // Re-trigger polling faster when transcribing
    onCurrentStateChanged: {
        if (currentState === "transcribing") {
            stateRefreshTimer.interval = 1500
        } else {
            stateRefreshTimer.interval = 3000
        }
    }

    // Whether the voxtype daemon is currently running
    property bool daemonRunning: false

    function updateState(newStatus) {
        currentState = newStatus
        switch (newStatus) {
        case "idle":
            statusText = "Voxtype is idle"
            break
        case "recording":
            statusText = "Voxtype is recording"
            break
        case "transcribing":
            statusText = "Voxtype is transcribing"
            break
        case "not-running":
            statusText = "Voxtype daemon not running"
            break
        default:
            statusText = "Voxtype is " + newStatus
        }
    }

    function refreshState() {
        stateReader.connectSource("cat " + root.stateFilePath + " 2>/dev/null || echo idle")
    }

    // Icon source based on current state
    readonly property string iconSource: {
        switch (currentState) {
        case "recording":
            return "media-record-symbolic"
        case "transcribing":
            return "content-loading-symbolic"
        case "not-running":
            return "dialog-warning-symbolic"
        case "idle":
        default:
            return "audio-input-microphone-symbolic"
        }
    }

    // Main clickable button
    PlasmaComponents.ToolButton {
        id: toggleButton
        anchors.centerIn: parent
        icon.name: root.iconSource
        onClicked: executable.toggleRecording()
    }

    // Initial state check when the component is ready
    Component.onCompleted: {
        refreshState()
        executable.checkDaemon()
    }
}

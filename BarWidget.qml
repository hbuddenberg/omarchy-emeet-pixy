import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "hbuddenberg.emeet-pixy"

  property string rawText: " ---"
  property string rawTooltip: "EMEET PIXY"
  property string rawClass: "custom-camera offline"

  readonly property bool inCall: rawClass.indexOf("in-call") !== -1
  readonly property bool isTracking: rawClass.indexOf("tracking") !== -1
  readonly property bool isPrivacy: rawClass.indexOf("privacy") !== -1
  readonly property bool isIdle: rawClass.indexOf("idle") !== -1
  readonly property bool isOffline: rawClass.indexOf("offline") !== -1

  readonly property bool iconOnly: root.setting("iconOnly", false)

  readonly property string displayText: {
    if (!root.rawText) return " ---"
    if (root.iconOnly) {
      var parts = root.rawText.split(" ")
      return parts[0] || root.rawText
    }
    return root.rawText
  }

  readonly property color stateColor: {
    if (root.isTracking) return "#10b981"
    if (root.isIdle) return "#fbbf24"
    if (root.isPrivacy) return "#f87171"
    if (root.isOffline) return "#78716c"
    return Color.foreground
  }

  readonly property string fullTooltip: {
    var tip = root.rawTooltip || "EMEET PIXY"
    tip += "\n\n• Clic izquierdo: Alternar privacidad\n• Clic derecho: Alternar modo auto\n• Clic central: Centrar cámara\n• Rueda: Zoom +/-"
    return tip
  }

  function pollState() {
    if (!statusProcess.running) {
      statusProcess.running = true
    }
  }

  function execute(cmdArgs) {
    if (root.bar && typeof root.bar.run === "function") {
      root.bar.run(cmdArgs.join(" "))
    } else {
      actionProcess.command = cmdArgs
      actionProcess.running = true
    }
    fastPollTimer.start()
  }

  Process {
    id: statusProcess
    command: ["emeet-pixy", "waybar"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var trimmed = (text || "").trim()
          if (trimmed.length > 0) {
            var data = JSON.parse(trimmed)
            root.rawText = data.text || " ---"
            root.rawTooltip = data.tooltip || "EMEET PIXY"
            root.rawClass = data.class || ""
          }
        } catch (e) {
          root.rawText = " ---"
          root.rawClass = "custom-camera offline"
        }
      }
    }
  }

  Process {
    id: actionProcess
    onExited: fastPollTimer.start()
  }

  Timer {
    id: pollTimer
    interval: 3000
    repeat: true
    running: true
    onTriggered: root.pollState()
  }

  Timer {
    id: fastPollTimer
    interval: 250
    repeat: false
    onTriggered: root.pollState()
  }

  Component.onCompleted: root.pollState()

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.0)
  implicitWidth: btn.implicitWidth + trailingGap
  implicitHeight: root.barSize

  WidgetButton {
    id: btn
    bar: root.bar
    text: root.displayText
    tooltipText: root.fullTooltip

    active: root.inCall || root.isTracking
    useActiveColor: true
    activeColor: root.inCall ? Color.urgent : root.stateColor
    foreground: root.stateColor
    opacity: root.isOffline ? 0.6 : 1.0

    horizontalMargin: 6
    verticalPadding: 6
    fixedWidth: root.vertical ? root.barSize : -1
    fixedHeight: root.barSize

    onPressed: function(button) {
      if (button === Qt.RightButton) {
        root.execute(["emeet-pixy", "toggle-auto"])
      } else if (button === Qt.MiddleButton) {
        root.execute(["emeet-pixy", "center"])
      } else {
        root.execute(["emeet-pixy", "toggle-privacy"])
      }
    }

    onWheelMoved: function(delta) {
      if (delta > 0) {
        root.execute(["emeet-pixy", "zoom", "rel+10"])
      } else if (delta < 0) {
        root.execute(["emeet-pixy", "zoom", "rel-10"])
      }
    }
  }
}

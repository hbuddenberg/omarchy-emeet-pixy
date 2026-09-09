import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "hbuddenberg.emeet-pixy"

  property string cameraMode: "offline"
  property string audioMode: "nc"
  property bool gestureEnabled: false
  property int panVal: 0
  property int tiltVal: 0
  property int zoomVal: 100
  property bool inCall: false
  property string autoMode: "off"
  property string devicePath: ""

  property bool popupOpen: false

  function close() {
    root.popupOpen = false
  }

  readonly property bool isTracking: cameraMode === "tracking"
  readonly property bool isPrivacy: cameraMode === "privacy"
  readonly property bool isIdle: cameraMode === "idle"
  readonly property bool isOffline: cameraMode === "offline"

  readonly property bool iconOnly: root.setting("iconOnly", false)

  readonly property string glyph: {
    if (root.isTracking) return ""
    if (root.isIdle) return ""
    if (root.isPrivacy) return ""
    return ""
  }

  readonly property string stateLabel: {
    if (root.isTracking) return "CAM"
    if (root.isIdle) return "IDLE"
    if (root.isPrivacy) return "OFF"
    return "---"
  }

  readonly property string autoBadge: {
    if (root.autoMode === "full") return "AUTO"
    if (root.autoMode === "tracking-only") return "TRK"
    if (root.autoMode === "privacy-only") return "PRV"
    return ""
  }

  readonly property string displayText: {
    if (root.iconOnly) return root.glyph
    if (root.autoBadge !== "") {
      return root.glyph + " " + root.stateLabel + " [" + root.autoBadge + "]"
    }
    return root.glyph + " " + root.stateLabel
  }

  readonly property color stateColor: {
    if (root.isTracking) return "#10b981"
    if (root.isIdle) return "#fbbf24"
    if (root.isPrivacy) return "#f87171"
    if (root.isOffline) return "#78716c"
    return Color.foreground
  }

  readonly property string fullTooltip: {
    var tip = "EMEET PIXY Camera"
    tip += "\n• Estado: " + root.cameraMode
    tip += "\n• Modo Auto: " + root.autoMode
    tip += "\n• Audio: " + root.audioMode
    tip += "\n• Gestos: " + (root.gestureEnabled ? "activos" : "inactivos")
    tip += "\n• Zoom: " + root.zoomVal + "%"
    tip += "\n• En llamada: " + (root.inCall ? "sí" : "no")
    tip += "\n\n🖱️ Clic izquierdo: Abrir panel de control"
    tip += "\n🖱️ Clic derecho: Alternar privacidad"
    tip += "\n🖱️ Clic central: Centrar cámara"
    tip += "\n🔄 Rueda: Zoom +/-"
    return tip
  }

  function applyStatus(output) {
    try {
      var trimmed = (output || "").trim()
      if (!trimmed) {
        root.cameraMode = "offline"
        return
      }
      var tokens = trimmed.split(/\s+/)
      var map = {}
      for (var i = 0; i < tokens.length; i++) {
        var kv = tokens[i].split("=")
        if (kv.length === 2) map[kv[0]] = kv[1]
      }
      root.cameraMode = map["camera"] || "offline"
      root.audioMode = map["audio"] || "nc"
      root.gestureEnabled = (map["gesture"] === "true")
      root.panVal = parseInt(map["pan"] || "0") || 0
      root.tiltVal = parseInt(map["tilt"] || "0") || 0
      root.zoomVal = parseInt(map["zoom"] || "100") || 100
      root.inCall = (map["in_call"] === "yes")
      root.autoMode = map["auto"] || "off"
      root.devicePath = map["device"] || ""
    } catch (e) {
      root.cameraMode = "offline"
    }
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
    command: ["emeet-pixy", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStatus(text)
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
    interval: 200
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
        root.execute(["emeet-pixy", "toggle-privacy"])
      } else if (button === Qt.MiddleButton) {
        root.execute(["emeet-pixy", "center"])
      } else {
        root.popupOpen = !root.popupOpen
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

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(330))
    contentHeight: popup.fittedContentHeight(contentCol.implicitHeight)

    Column {
      id: contentCol
      width: parent.width
      spacing: Style.space(8)

      // Header
      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Text {
          text: "📹 EMEET PIXY"
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.heading
          font.bold: true
          Layout.fillWidth: true
        }

        BorderSurface {
          radius: Style.cornerRadius
          color: root.stateColor
          implicitWidth: statusText.implicitWidth + Style.space(12)
          implicitHeight: Style.space(20)

          Text {
            id: statusText
            anchors.centerIn: parent
            text: root.cameraMode.toUpperCase()
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }
      }

      PanelSeparator {}

      // Section: Camera Mode
      PanelSectionHeader {
        text: "MODO DE CÁMARA"
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: "Privacidad"
          selected: root.isPrivacy
          onClicked: root.execute(["emeet-pixy", "privacy"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: "Tracking"
          selected: root.isTracking
          onClicked: root.execute(["emeet-pixy", "track"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: "Reposo"
          selected: root.isIdle
          onClicked: root.execute(["emeet-pixy", "idle"])
        }
      }

      PanelSeparator {}

      // Section: Automation / Auto Mode
      PanelSectionHeader {
        text: "AUTOMATIZACIÓN (MODO AUTO)"
      }

      Grid {
        columns: 2
        spacing: Style.space(6)
        width: parent.width

        Button {
          width: Math.floor((parent.width - Style.space(6)) / 2)
          bordered: true
          iconText: "󰚩"
          text: "Completo"
          tooltipText: "Seguimiento + NC + Privacidad al colgar"
          selected: root.autoMode === "full"
          onClicked: root.execute(["emeet-pixy", "auto", "full"])
        }

        Button {
          width: Math.floor((parent.width - Style.space(6)) / 2)
          bordered: true
          iconText: "󰄀"
          text: "Solo Tracking"
          tooltipText: "Solo seguimiento facial automático"
          selected: root.autoMode === "tracking-only"
          onClicked: root.execute(["emeet-pixy", "auto", "tracking-only"])
        }

        Button {
          width: Math.floor((parent.width - Style.space(6)) / 2)
          bordered: true
          iconText: "󰄂"
          text: "Solo Privacidad"
          tooltipText: "Solo tapar lente al colgar"
          selected: root.autoMode === "privacy-only"
          onClicked: root.execute(["emeet-pixy", "auto", "privacy-only"])
        }

        Button {
          width: Math.floor((parent.width - Style.space(6)) / 2)
          bordered: true
          iconText: "󰅙"
          text: "Desactivado"
          tooltipText: "Sin automatizaciones de llamada"
          selected: root.autoMode === "off"
          onClicked: root.execute(["emeet-pixy", "auto", "off"])
        }
      }

      PanelSeparator {}

      // Section: Audio Mode
      PanelSectionHeader {
        text: "MICRÓFONO Y AUDIO"
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: "Reducción Ruido"
          selected: root.audioMode === "nc"
          onClicked: root.execute(["emeet-pixy", "audio", "nc"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: "Live"
          selected: root.audioMode === "live"
          onClicked: root.execute(["emeet-pixy", "audio", "live"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: "Original"
          selected: root.audioMode === "org"
          onClicked: root.execute(["emeet-pixy", "audio", "org"])
        }
      }

      PanelSeparator {}

      // Section: PTZ & Zoom
      PanelSectionHeader {
        text: "CONTROLES PTZ Y ZOOM (" + root.zoomVal + "%)"
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🎯"
          text: "Centrar"
          onClicked: root.execute(["emeet-pixy", "center"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🔍"
          text: "Zoom +"
          onClicked: root.execute(["emeet-pixy", "zoom", "rel+10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🔍"
          text: "Zoom -"
          onClicked: root.execute(["emeet-pixy", "zoom", "rel-10"])
        }
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          text: "◄ Izquierda"
          onClicked: root.execute(["emeet-pixy", "pan", "rel-15"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: "▲ Arriba"
          onClicked: root.execute(["emeet-pixy", "tilt", "rel+10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: "▼ Abajo"
          onClicked: root.execute(["emeet-pixy", "tilt", "rel-10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: "► Derecha"
          onClicked: root.execute(["emeet-pixy", "pan", "rel+15"])
        }
      }

      PanelSeparator {}

      // Section: Gestures
      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "✋"
          text: root.gestureEnabled ? "Control Gestual: Activo" : "Control Gestual: Inactivo"
          selected: root.gestureEnabled
          onClicked: root.execute(["emeet-pixy", "toggle-gesture"])
        }
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Ui
import "i18n.js" as I18n

BarWidget {
  id: root
  moduleName: "hbuddenberg.emeet-pixy"

  readonly property string currentLang: I18n.resolveLanguage(root.setting("language", "auto"), Qt.locale().name)

  function t(key) {
    return I18n.t(key, root.currentLang)
  }

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
  readonly property bool opened: popupOpen

  function open() {
    root.popupOpen = true
  }

  function close() {
    root.popupOpen = false
  }

  function toggle() {
    root.popupOpen = !root.popupOpen
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

  readonly property bool showAutoBadge: root.setting("showAutoBadge", false)

  readonly property string displayText: {
    if (root.iconOnly) return root.glyph
    if (root.showAutoBadge && root.autoBadge !== "") {
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

  readonly property var pwNodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property var emeetSource: {
    for (var i = 0; i < root.pwNodes.length; i++) {
      var n = root.pwNodes[i]
      if (n && !n.isSink && !n.isStream) {
        var str = ((n.name || "") + " " + (n.description || "") + " " + (n.nickname || "") + " " + (n.nick || "")).toLowerCase()
        if (str.indexOf("emeet") !== -1 || str.indexOf("pixy") !== -1) {
          return n
        }
      }
    }
    return null
  }

  PwObjectTracker {
    objects: root.emeetSource ? [root.emeetSource] : []
  }

  property bool fallbackMicMuted: false

  readonly property bool isMicMuted: {
    if (root.emeetSource && root.emeetSource.audio) {
      return root.emeetSource.audio.muted
    }
    return root.fallbackMicMuted
  }

  function toggleMicMute() {
    if (root.emeetSource && root.emeetSource.audio) {
      root.emeetSource.audio.muted = !root.emeetSource.audio.muted
    } else {
      root.fallbackMicMuted = !root.fallbackMicMuted
      Quickshell.execDetached(["sh", "-c", "SRC=$(pactl list sources short | awk '$2 ~ /EMEET/ {print $2; exit}'); [ -n \"$SRC\" ] && pactl set-source-mute \"$SRC\" toggle"])
    }
    if (!micStatusProcess.running) {
      micStatusProcess.running = true
    }
  }

  readonly property string fullTooltip: {
    if (root.isOffline) return root.t("tip.offline")
    var tip = root.t("header.title")
    tip += "\n• " + (root.isTracking ? root.t("tip.tracking") : (root.isPrivacy ? root.t("tip.privacy") : root.t("tip.standby")))
    tip += "\n• " + root.t("tip.auto_mode") + root.autoMode
    tip += "\n• " + root.t("tip.audio_mode") + root.audioMode
    tip += "\n• " + (root.isMicMuted ? root.t("tip.mic_muted") : root.t("tip.mic_active"))
    tip += "\n• " + (root.gestureEnabled ? root.t("tip.gestures_on") : root.t("tip.gestures_off"))
    tip += "\n• Zoom: " + root.zoomVal + "%"
    tip += "\n• " + (root.inCall ? root.t("tip.call_active") : root.t("tip.call_inactive"))
    tip += "\n\n🖱️ " + root.t("tip.hint_left")
    tip += "\n🖱️ " + root.t("tip.hint_right")
    tip += "\n🖱️ " + root.t("tip.hint_middle")
    tip += "\n🔄 " + root.t("tip.hint_wheel")
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
    if (!root.emeetSource && !micStatusProcess.running) {
      micStatusProcess.running = true
    }
  }

  function execute(cmdArgs) {
    Quickshell.execDetached(cmdArgs)
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
    id: micStatusProcess
    command: ["sh", "-c", "pactl list sources | awk '/Name: .*EMEET/{flag=1} flag && /Mute:/{print $2; exit}'"]
    stdout: StdioCollector {
      id: micCollector
      waitForEnd: true
      onStreamFinished: {
        var res = (micCollector.text || "").trim().toLowerCase()
        if (res === "yes") {
          root.fallbackMicMuted = true
        } else if (res === "no") {
          root.fallbackMicMuted = false
        }
      }
    }
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
    anchors.fill: parent
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
        root.toggle()
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

  KeyboardPanel {
    id: popup
    anchorItem: btn
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(340))
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
          text: "📹 " + root.t("header.title")
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
        text: root.t("section.camera_mode")
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: root.t("mode.privacy")
          selected: root.isPrivacy
          onClicked: root.execute(["emeet-pixy", "privacy"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: root.t("mode.tracking")
          selected: root.isTracking
          onClicked: root.execute(["emeet-pixy", "track"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: ""
          text: root.t("mode.standby")
          selected: root.isIdle
          onClicked: root.execute(["emeet-pixy", "idle"])
        }
      }

      PanelSeparator {}

      // Section: Automation / Auto Mode
      PanelSectionHeader {
        text: root.t("section.auto_mode")
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰚩"
          text: root.t("auto.full")
          tooltipText: root.t("auto.full_tip")
          selected: root.autoMode === "full"
          onClicked: root.execute(["emeet-pixy", "auto", "full"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰄀"
          text: root.t("auto.tracking")
          tooltipText: root.t("auto.tracking_tip")
          selected: root.autoMode === "tracking-only"
          onClicked: root.execute(["emeet-pixy", "auto", "tracking-only"])
        }
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰄂"
          text: root.t("auto.privacy")
          tooltipText: root.t("auto.privacy_tip")
          selected: root.autoMode === "privacy-only"
          onClicked: root.execute(["emeet-pixy", "auto", "privacy-only"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰅙"
          text: root.t("auto.off")
          tooltipText: root.t("auto.off_tip")
          selected: root.autoMode === "off"
          onClicked: root.execute(["emeet-pixy", "auto", "off"])
        }
      }

      PanelSeparator {}

      // Section: Audio Mode
      PanelSectionHeader {
        text: root.t("section.audio_mode")
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: root.t("audio.nc")
          selected: root.audioMode === "nc"
          onClicked: root.execute(["emeet-pixy", "audio", "nc"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: root.t("audio.live")
          selected: root.audioMode === "live"
          onClicked: root.execute(["emeet-pixy", "audio", "live"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "󰍬"
          text: root.t("audio.original")
          selected: root.audioMode === "org"
          onClicked: root.execute(["emeet-pixy", "audio", "org"])
        }
      }

      Toggle {
        width: parent.width
        label: root.t("audio.mic_title")
        description: root.isMicMuted ? root.t("audio.mic_muted_desc") : root.t("audio.mic_active_desc")
        checked: !root.isMicMuted
        onClicked: root.toggleMicMute()
      }

      PanelSeparator {}

      // Section: PTZ & Zoom
      PanelSectionHeader {
        text: root.t("section.ptz") + " (" + root.zoomVal + "%)"
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🎯"
          text: root.t("ptz.center")
          onClicked: root.execute(["emeet-pixy", "center"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🔍"
          text: root.t("ptz.zoom_in")
          onClicked: root.execute(["emeet-pixy", "zoom", "rel+10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          iconText: "🔍"
          text: root.t("ptz.zoom_out")
          onClicked: root.execute(["emeet-pixy", "zoom", "rel-10"])
        }
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          bordered: true
          text: root.t("ptz.left")
          onClicked: root.execute(["emeet-pixy", "pan", "rel-15"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: root.t("ptz.up")
          onClicked: root.execute(["emeet-pixy", "tilt", "rel+10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: root.t("ptz.down")
          onClicked: root.execute(["emeet-pixy", "tilt", "rel-10"])
        }

        Button {
          Layout.fillWidth: true
          bordered: true
          text: root.t("ptz.right")
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
          text: root.gestureEnabled ? root.t("gesture.active") : root.t("gesture.inactive")
          selected: root.gestureEnabled
          onClicked: root.execute(["emeet-pixy", "toggle-gesture"])
        }
      }
    }
  }
}

# EMEET PIXY — Omarchy Shell Plugin

Native [Omarchy](https://omarchy.org/) Quickshell bar widget for the [EMEET PIXY](https://github.com/LarsArtmann/emeet-pixyd) webcam auto-activation daemon.

Provides real-time camera status, privacy controls, PTZ presets, and interactive gestures directly from the Omarchy status bar.

![Omarchy Plugin](https://img.shields.io/badge/omarchy-plugin-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## Features

- **Real-Time Camera State:** Dynamically monitors daemon status, audio mode, auto-framing, and active calls.
- **Color-Coded Status Indicators:**
  - ` CAM` (Emerald): Camera tracking active.
  - ` IDLE` (Amber): Standby / idle mode.
  - ` OFF` (Red): Privacy mode active.
  - ` ---` (Muted): Camera offline or daemon disconnected.
- **Interactive Mouse Controls:**
  - **Left Click:** Toggle privacy mode (`emeet-pixy toggle-privacy`).
  - **Right Click:** Toggle auto mode (`emeet-pixy toggle-auto`).
  - **Middle Click:** Center camera and reset PTZ (`emeet-pixy center`).
  - **Scroll Wheel:** Zoom in / out (`emeet-pixy zoom rel±10`).
- **Detailed Tooltip:** Hover to inspect daemon state, active audio configuration, auto-tracking mode, and call detection.

---

## Prerequisites

Ensure `emeet-pixyd` is installed and running on your system:

```bash
# Verify CLI and daemon status
emeet-pixy status
```

---

## Installation

Install directly using the Omarchy CLI:

```bash
omarchy plugin add https://github.com/hbuddenberg/omarchy-emeet-pixy.git --enable
```

Or enable it manually in `~/.config/omarchy/shell.json`:

```json
{
  "bar": {
    "layout": {
      "right": [
        {
          "id": "hbuddenberg.emeet-pixy"
        }
      ]
    }
  },
  "plugins": [
    {
      "id": "hbuddenberg.emeet-pixy"
    }
  ]
}
```

---

## Configuration

The widget supports inline settings in `shell.json`:

```json
{
  "id": "hbuddenberg.emeet-pixy",
  "iconOnly": false
}
```

- `iconOnly` (boolean, default: `false`): When `true`, displays only the status glyph without the state label.

---

## License

[MIT](LICENSE) © [Hans-Dieter Buddenberg](https://github.com/hbuddenberg)

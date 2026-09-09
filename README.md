# EMEET PIXY — Omarchy Shell Plugin

Native [Omarchy](https://omarchy.org/) Quickshell bar widget for the [EMEET PIXY](https://github.com/LarsArtmann/emeet-pixyd) webcam auto-activation daemon.

Provides real-time camera status, privacy controls, PTZ presets, and interactive gestures directly from the Omarchy status bar.

![Omarchy Plugin](https://img.shields.io/badge/omarchy-plugin-blue?style=flat-square)
[![CI](https://github.com/hbuddenberg/omarchy-emeet-pixy/actions/workflows/ci.yml/badge.svg)](https://github.com/hbuddenberg/omarchy-emeet-pixy/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## Features

- **Interactive Control Menu (`KeyboardPanel`):** Left-click the widget to open a Wayland-native layer-shell control panel featuring:
  - **Camera Modes:** Switch between Privacy, AI Face Tracking, and Standby (Idle).
  - **Auto Automation Strategies:** Toggle between `Full` (tracking + NC + privacy on call end), `Tracking-Only`, `Privacy-Only`, or `Off` (manual).
  - **Microphone Audio Modes:** Noise Cancellation (`nc`), Live (`live`), and Original (`org`).
  - **Full PTZ & Zoom Controls:** Interactive Pan left/right, Tilt up/down, Zoom in/out, and 1-click Center.
  - **AI Gesture Controls:** Toggle gesture recognition on or off.
- **Internationalization (i18n):** Native English and Spanish support with automatic system locale detection (`es_*` / `en_*`) and manual configuration override.
- **Bar Status & Auto Indicators:**
  - ` CAM [AUTO]` (Emerald): Active tracking with automation enabled.
  - ` IDLE` (Amber): Standby mode.
  - ` OFF [AUTO]` (Red): Hardware privacy shutter active.
  - ` ---` (Muted): Camera offline or daemon disconnected.
- **Fast Mouse Shortcuts:**
  - **Left Click:** Open / close the interactive control menu.
  - **Right Click:** Quick-toggle privacy mode (`toggle-privacy`).
  - **Middle Click:** Quick-center camera and reset PTZ (`center`).
  - **Scroll Wheel:** Dynamic zoom adjustment (`zoom rel±10`).
- **Comprehensive Tooltip:** Hover to inspect real-time daemon state, active audio preset, auto mode, call detection, and gestures.

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
  "iconOnly": false,
  "language": "auto"
}
```

- `iconOnly` (boolean, default: `false`): When `true`, displays only the status glyph without the state label.
- `language` (string, default: `"auto"`): Interface language. Options: `"auto"` (system locale), `"en"`, `"es"`.

---

## License

[MIT](LICENSE) © [Hans-Dieter Buddenberg](https://github.com/hbuddenberg)

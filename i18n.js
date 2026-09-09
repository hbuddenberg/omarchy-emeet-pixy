.pragma library

var strings = {
  en: {
    // Tooltips
    "tip.offline": "EMEET PIXY: Offline / Disconnected",
    "tip.tracking": "Camera: Tracking active",
    "tip.standby": "Camera: Standby / Idle",
    "tip.privacy": "Camera: Privacy mode active",
    "tip.call_active": "In call: Yes",
    "tip.call_inactive": "In call: No",
    "tip.audio_mode": "Audio mode: ",
    "tip.mic_active": "Microphone: Live",
    "tip.mic_muted": "Microphone: Off (Muted)",
    "tip.auto_mode": "Auto mode: ",
    "tip.gestures_on": "Gestures: Enabled",
    "tip.gestures_off": "Gestures: Disabled",
    "tip.hint_left": "Left click: Open control panel",
    "tip.hint_right": "Right click: Toggle privacy",
    "tip.hint_middle": "Middle click: Center camera",
    "tip.hint_wheel": "Scroll wheel: Zoom +/-",

    // Panel Header & Sections
    "header.title": "EMEET PIXY",
    "section.camera_mode": "CAMERA MODE",
    "section.camera_mode_tip": "Camera power and video modes: USB soft-disconnect, hardware privacy shutter, AI face tracking, or idle standby.",
    "section.auto_mode": "AUTOMATION (AUTO MODE)",
    "section.auto_mode_tip": "Automation rules triggered on calls: Auto-tracking, noise cancellation, and auto-privacy.",
    "section.audio_mode": "MICROPHONE & AUDIO",
    "section.audio_mode_tip": "Built-in microphone and DSP processing: Mute camera audio and switch noise cancellation presets (NC, Live, Original).",
    "section.ptz": "PTZ & ZOOM CONTROLS",
    "section.ptz_tip": "Motorized gimbal controls: Horizontal pan, vertical tilt, digital zoom, and center reset.",
    "section.gestures": "GESTURES",

    // Camera Modes & Power
    "camera.power_title": "EMEET PIXY Camera",
    "camera.power_on_desc": "Connected to system",
    "camera.power_off_desc": "Completely off (Disconnected)",
    "mode.privacy": "Privacy",
    "mode.tracking": "Tracking",
    "mode.standby": "Standby",

    // Auto Modes
    "auto.full": "Full",
    "auto.full_tip": "Tracking + NC + Privacy on call end",
    "auto.tracking": "Tracking",
    "auto.tracking_tip": "Automatic face tracking only",
    "auto.privacy": "Privacy",
    "auto.privacy_tip": "Shutter closes on call end only",
    "auto.off": "Off",
    "auto.off_tip": "Manual mode, no call automation",

    // Audio Modes & Microphone
    "audio.mic_title": "EMEET PIXY Microphone",
    "audio.mic_active_desc": "On (Capturing audio)",
    "audio.mic_muted_desc": "Off (Muted)",
    "audio.nc": "Noise Cancelling",
    "audio.live": "Live",
    "audio.original": "Original",
    "audio.mic_active": "Microphone: Live",
    "audio.mic_muted": "Microphone: Off",
    "audio.mic_mute_tip": "Click to turn off / mute camera microphone",
    "audio.mic_unmute_tip": "Click to turn on / unmute camera microphone",

    // PTZ & Zoom Controls
    "ptz.center": "Center",
    "ptz.zoom_in": "Zoom +",
    "ptz.zoom_out": "Zoom -",
    "ptz.left": "◄ Left",
    "ptz.right": "Right ►",
    "ptz.up": "▲ Up",
    "ptz.down": "▼ Down",

    // Gestures
    "gesture.active": "Gestures: Active",
    "gesture.inactive": "Gestures: Inactive"
  },
  es: {
    // Tooltips
    "tip.offline": "EMEET PIXY: Desconectada / Sin señal",
    "tip.tracking": "Cámara: Seguimiento activo",
    "tip.standby": "Cámara: En reposo",
    "tip.privacy": "Cámara: Modo privacidad activo",
    "tip.call_active": "En llamada: Sí",
    "tip.call_inactive": "En llamada: No",
    "tip.audio_mode": "Modo de audio: ",
    "tip.mic_active": "Micrófono: Activo",
    "tip.mic_muted": "Micrófono: Apagado (Silenciado)",
    "tip.auto_mode": "Modo auto: ",
    "tip.gestures_on": "Control gestual: Activado",
    "tip.gestures_off": "Control gestual: Desactivado",
    "tip.hint_left": "Clic izquierdo: Abrir panel de control",
    "tip.hint_right": "Clic derecho: Alternar privacidad",
    "tip.hint_middle": "Clic central: Centrar cámara",
    "tip.hint_wheel": "Rueda: Zoom +/-",

    // Panel Header & Sections
    "header.title": "EMEET PIXY",
    "section.camera_mode": "MODO DE CÁMARA",
    "section.camera_mode_tip": "Control de alimentación y video: Desconexión por software, obturador físico de privacidad, seguimiento facial por IA o reposo.",
    "section.auto_mode": "AUTOMATIZACIÓN (MODO AUTO)",
    "section.auto_mode_tip": "Comportamientos automáticos en llamada: Auto-tracking, reducción de ruido y cierre automático del obturador.",
    "section.audio_mode": "MICRÓFONO Y AUDIO",
    "section.audio_mode_tip": "Micrófono integrado y procesamiento DSP: Silenciar entrada de audio y alternar reducción de ruido (NC, Live, Original).",
    "section.ptz": "CONTROLES PTZ Y ZOOM",
    "section.ptz_tip": "Control motorizado de movimiento: Paneo horizontal, inclinación vertical, zoom digital y recentrado del gimbal.",
    "section.gestures": "GESTOS",

    // Camera Modes & Power
    "camera.power_title": "Cámara EMEET PIXY",
    "camera.power_on_desc": "Conectada al sistema",
    "camera.power_off_desc": "Apagada por software (Desconectada)",
    "mode.privacy": "Privacidad",
    "mode.tracking": "Tracking",
    "mode.standby": "Reposo",

    // Auto Modes
    "auto.full": "Completo",
    "auto.full_tip": "Seguimiento + NC + Privacidad al colgar",
    "auto.tracking": "Tracking",
    "auto.tracking_tip": "Solo seguimiento facial automático",
    "auto.privacy": "Privacidad",
    "auto.privacy_tip": "Solo tapar lente al colgar",
    "auto.off": "Desactivado",
    "auto.off_tip": "Sin automatizaciones de llamada",

    // Audio Modes & Microphone
    "audio.mic_title": "Micrófono EMEET PIXY",
    "audio.mic_active_desc": "Encendido (Capturando)",
    "audio.mic_muted_desc": "Apagado (Silenciado)",
    "audio.nc": "Reducción Ruido",
    "audio.live": "Live",
    "audio.original": "Original",
    "audio.mic_active": "Micrófono: Activo",
    "audio.mic_muted": "Micrófono: Apagado",
    "audio.mic_mute_tip": "Clic para apagar / silenciar el micrófono",
    "audio.mic_unmute_tip": "Clic para reactivar el micrófono",

    // PTZ & Zoom Controls
    "ptz.center": "Centrar",
    "ptz.zoom_in": "Zoom +",
    "ptz.zoom_out": "Zoom -",
    "ptz.left": "◄ Izquierda",
    "ptz.right": "Derecha ►",
    "ptz.up": "▲ Arriba",
    "ptz.down": "▼ Abajo",

    // Gestures
    "gesture.active": "Control Gestual: Activo",
    "gesture.inactive": "Control Gestual: Inactivo"
  }
};

function resolveLanguage(settingLang, systemLocale) {
  var lang = String(settingLang || "auto").trim().toLowerCase();
  if (lang === "es" || lang === "en") return lang;
  var loc = String(systemLocale || "").toLowerCase();
  if (loc.indexOf("es") === 0) return "es";
  return "en";
}

function t(key, lang) {
  var l = lang === "es" ? "es" : "en";
  if (strings[l] && strings[l][key] !== undefined) {
    return strings[l][key];
  }
  if (strings["en"] && strings["en"][key] !== undefined) {
    return strings["en"][key];
  }
  return key;
}

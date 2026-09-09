import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
manifest_path = root / "manifest.json"
assert manifest_path.is_file(), "manifest.json not found"

manifest = json.loads(manifest_path.read_text())

# Omarchy plugin contract assertions
assert manifest.get("schemaVersion") == 1, "schemaVersion must be 1"
assert manifest.get("id") == "hbuddenberg.emeet-pixy", "id mismatch"
assert "bar-widget" in manifest.get("kinds", []), "kinds must contain bar-widget"
assert "entryPoints" in manifest, "entryPoints missing"
assert manifest["entryPoints"].get("barWidget") == "BarWidget.qml", "barWidget entryPoint must be BarWidget.qml"

for entry_point_name, relative_file in manifest["entryPoints"].items():
    file_path = root / relative_file
    assert file_path.is_file(), f"entryPoint {entry_point_name} pointing to missing file: {relative_file}"

bar_widget = manifest.get("barWidget", {})
assert bar_widget.get("defaultSection") in ("left", "center", "right"), "defaultSection invalid"

# QML file validation
qml_path = root / "BarWidget.qml"
assert qml_path.is_file(), "BarWidget.qml not found"
qml_text = qml_path.read_text()
assert "moduleName: \"hbuddenberg.emeet-pixy\"" in qml_text, "moduleName missing in BarWidget.qml"
assert "BarWidget {" in qml_text, "BarWidget root element missing"
assert "WidgetButton {" in qml_text, "WidgetButton element missing"
assert qml_text.count("{") == qml_text.count("}"), "Unbalanced braces in BarWidget.qml"

print("All manifest and QML assertions passed successfully!")

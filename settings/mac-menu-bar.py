"""Hide selected app icons in the macOS Control Center preference domain."""

import plistlib
import subprocess
import sys
from pathlib import Path


def hide_apps(domain: str, bundle_ids: list[str]) -> None:
    """Merge hidden bundle IDs into an absolute defaults domain, or raise if unreadable."""
    defaults = "/usr/bin/defaults"
    outer = plistlib.loads(subprocess.check_output([defaults, "export", domain, "-"]))
    if not isinstance(outer, dict):
        raise ValueError("Unexpected Control Center preference format")
    if not outer and Path(f"{domain}.plist").exists():
        raise PermissionError("Control Center preferences could not be read")

    key = "trackedApplications"
    rows = plistlib.loads(outer[key]) if key in outer else []
    if not isinstance(rows, list) or len(rows) % 2 or not all(isinstance(row, dict) for row in rows):
        raise ValueError("Unexpected menu bar app preference format")

    preferences_by_bundle = {}
    for app, preferences in zip(rows[::2], rows[1::2], strict=True):
        bundle_id = app.get("bundle", {}).get("_0")
        preferences_by_bundle.setdefault(bundle_id, preferences)

    changed = False
    for bundle_id in sorted(set(bundle_ids)):
        preferences = preferences_by_bundle.get(bundle_id)
        if preferences is None:
            app = {"bundle": {"_0": bundle_id}}
            preferences = {"location": app, "menuItemLocations": [app]}
            rows.extend([app, preferences])

        if preferences.get("isAllowed") is not False:
            preferences["isAllowed"] = False
            changed = True

    if not changed:
        return

    # Import only the updated key and preserve other Control Center preferences
    update = {key: plistlib.dumps(rows, fmt=plistlib.FMT_BINARY)}
    subprocess.run([defaults, "import", domain, "-"], input=plistlib.dumps(update), check=True)


if __name__ == "__main__":
    try:
        hide_apps(sys.argv[1], sys.argv[2:])
    except (OSError, subprocess.CalledProcessError, ValueError) as error:
        sys.exit(str(error))

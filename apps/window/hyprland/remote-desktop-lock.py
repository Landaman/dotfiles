import getpass
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import TextIO, cast


def output(*command: str) -> str:
    """Return stdout from command or raise if it fails."""
    return subprocess.check_output(command, text=True, timeout=10).strip()


def locked() -> bool:
    """Return the physical compositor's lock state."""
    return {"true": True, "false": False}[output("hyprctl", "locked")]


def locker_pid() -> int:
    """Return the main PID of Hyprlock, or zero if the service has no process."""
    return int(
        output("systemctl", "--user", "show", "-p", "MainPID", "--value", "hyprlock.service")
    )


def graphical_session_active() -> bool:
    """Return whether UWSM is still running the physical session."""
    return output(
        "systemctl", "--user", "show", "-p", "ActiveState", "--value", "graphical-session.target"
    ) == "active"


def restore(marker: Path) -> None:
    """Re-lock the session unlocked by the watcher and clear the marker."""
    if not marker.exists():
        return

    previous_pid = int(marker.read_text())
    # Let the signalled locker finish unlocking before trying to start it again
    for _ in range(50):
        if locker_pid() != previous_pid:
            break
        time.sleep(0.1)
    else:
        raise RuntimeError("Hyprlock did not finish the remote unlock")

    if not locked():
        _ = output("systemctl", "--user", "start", "--no-block", "hyprlock.service")
        for _ in range(50):
            if locked():
                break
            time.sleep(0.1)
        else:
            raise RuntimeError("The physical session did not re-lock")
    marker.unlink()


def watch(marker: Path, socket: str) -> None:
    """Watch authenticated clients on socket and manage the physical lock."""
    restore(marker)
    control = ("wayvncctl", "--json", "--socket", socket)
    user = getpass.getuser()
    with subprocess.Popen(
        (*control, "--wait", "event-receive"), stdout=subprocess.PIPE, text=True
    ) as events:
        try:
            stdout = cast("TextIO | None", events.stdout)
            assert stdout is not None  # Popen creates this stream with stdout=PIPE
            for line in stdout:
                event = cast("dict[str, object]", json.loads(line))
                method = event["method"]
                if method not in {"client-connected", "client-disconnected"}:
                    continue

                params = cast("dict[str, object]", event["params"])
                count = params["connection_count"]
                if method == "client-disconnected" and count == 0:
                    restore(marker)
                elif (
                    method == "client-connected"
                    and count == 1
                    and params["username"] == user
                    and locked()
                ):
                    pid = locker_pid()
                    if pid:
                        _ = marker.write_text(str(pid))
                        _ = output(
                            "systemctl", "--user", "kill", "--kill-whom=main",
                            "--signal=SIGUSR1", "hyprlock.service",
                        )
        finally:
            events.terminate()
    raise RuntimeError("Lost the WayVNC control connection")


if __name__ == "__main__":
    marker = Path(os.environ["RUNTIME_DIRECTORY"]) / "unlocked"
    if sys.argv[1] == "watch":
        watch(marker, sys.argv[2])
    elif marker.exists() and graphical_session_active():
        # The compositor is already going away when the graphical target stops
        restore(marker)

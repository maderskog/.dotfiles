#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import signal
import subprocess
import sys

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore[no-redef]


HOME = Path.home()
CONFIG_DIR = HOME / ".config"
DOWNLOADS_DIR = HOME / "Downloads"
AGENT_FILES_CONFIG = CONFIG_DIR / "television" / "agent-files.toml"

COMMON_EXCLUDES = [
    ".git",
    "node_modules",
    ".cache",
    ".local",
    ".cargo",
    ".rustup",
    ".mix",
    ".npm",
    ".pnpm-store",
    ".bundle",
    ".gem",
    "Library",
    "target",
    "dist",
    "build",
]


def load_agent_files() -> list[tuple[Path, str]]:
    if not AGENT_FILES_CONFIG.exists():
        return []
    data = tomllib.loads(AGENT_FILES_CONFIG.read_text())
    return [
        (Path(entry["path"].replace("~", str(HOME))), entry["label"])
        for entry in data.get("file", [])
    ]


def run_command(command: list[str]) -> list[str]:
    result = subprocess.run(command, capture_output=True, text=True, errors="replace")
    return [line for line in result.stdout.splitlines() if line.strip()]


def fd_command(hidden: bool, root: str | None = None) -> list[str]:
    command = ["fd", "-t", "f", "--max-results", "5000"]
    if hidden:
        command.append("-H")
    for pattern in COMMON_EXCLUDES:
        command.extend(["-E", pattern])
    if root:
        command.extend([".", root])
    return command


def home_label(path: str) -> str:
    return path.replace(f"{HOME}/", "~/")


def unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            ordered.append(value)
    return ordered


def default_display(path: str) -> str:
    short_path = home_label(path)
    parts = [part for part in Path(short_path).parts if part not in {"/"}]
    if len(parts) <= 3:
        return short_path
    focus = "/".join(parts[-3:])
    return f"{focus} — {short_path}"


def search_key(path: str, label: str) -> str:
    short_path = home_label(path)
    parts = [part for part in Path(short_path).parts if part not in {"/"}]
    basename = parts[-1] if parts else short_path
    directories = list(reversed(parts[:-1]))
    tokens = unique([basename, *directories, short_path, label])
    return " ".join(tokens)


def print_entry(path: str, label: str | None = None) -> None:
    display = label or default_display(path)
    print(f"{search_key(path, display)}\t{path}\t{display}")


def current_priority(path: str) -> tuple[int, str]:
    short_path = home_label(path)
    if short_path.startswith(".config/"):
        return 0, short_path
    if short_path.startswith("src/"):
        return 1, short_path
    if short_path.startswith("."):
        return 2, short_path
    if short_path.startswith("Downloads/"):
        return 3, short_path
    return 4, short_path


def list_current(hidden: bool) -> int:
    paths = run_command(fd_command(hidden=hidden))
    for path in sorted(paths, key=current_priority):
        print_entry(path)
    return 0


def list_config() -> int:
    command = fd_command(hidden=False, root=str(CONFIG_DIR))
    command.extend(["-E", "television-disabled-channels"])
    for path in run_command(command):
        print_entry(path, home_label(path))
    return 0


def list_downloads() -> int:
    command = fd_command(hidden=False, root=str(DOWNLOADS_DIR))
    command[4] = "200"
    for path in run_command(command):
        print_entry(path, home_label(path))
    return 0


def list_agent_files() -> int:
    for path, label in load_agent_files():
        if path.exists():
            print_entry(str(path), label)
    return 0


def usage() -> str:
    return "usage: files_sources.py [current|hidden|config|downloads|agent-files]"


def main() -> int:
    if len(sys.argv) < 2:
        print(usage(), file=sys.stderr)
        return 1
    mode = sys.argv[1]
    if mode == "current":
        return list_current(hidden=False)
    if mode == "hidden":
        return list_current(hidden=True)
    if mode == "config":
        return list_config()
    if mode == "downloads":
        return list_downloads()
    if mode == "agent-files":
        return list_agent_files()
    print(usage(), file=sys.stderr)
    return 1


if __name__ == "__main__":
    if hasattr(signal, "SIGPIPE"):
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    raise SystemExit(main())

#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import subprocess
import sys
import tomllib


CONFIG_DIR = Path.home() / ".config" / "television"
CABLE_DIR = CONFIG_DIR / "cable"
GROUPS = {
    "core": [
        "alias",
        "channels",
        "dirs",
        "env",
        "files",
        "git-repos",
        "rtfm",
        "network-interfaces",
        "path",
        "procs",
        "ssh-hosts",
        "tmux-sessions",
        "tmux-windows",
    ],
    "code": [
        "gh-issues",
        "gh-prs",
        "git-branch",
        "git-diff",
        "git-files",
        "git-log",
        "git-reflog",
        "git-remotes",
        "git-stash",
        "git-submodules",
        "git-tags",
        "git-worktrees",
        "make-targets",
        "text",
        "todo-comments",
    ],
    "infra": [
        "crontab",
        "docker-compose",
        "docker-containers",
        "docker-images",
        "docker-networks",
        "docker-volumes",
        "k8s-contexts",
        "k8s-deployments",
        "k8s-pods",
        "k8s-services",
        "tailscale-exit-node",
    ],
    "tooling": [
        "brew-packages",
        "cargo-commands",
        "cargo-crates",
        "node-packages",
        "npm-packages",
        "npm-scripts",
        "pip-packages",
        "python-venvs",
        "rustup",
    ],
}


@dataclass(frozen=True)
class Channel:
    name: str
    description: str
    path: Path | None = None


def run_command(command: list[str]) -> tuple[int, str]:
    result = subprocess.run(command, capture_output=True, text=True, errors="replace")
    output = result.stdout if result.stdout else result.stderr
    return result.returncode, output.strip()


def available_channel_names() -> list[str]:
    _, output = run_command(["tv", "list-channels"])
    return [line.strip() for line in output.splitlines() if line.strip()]


def first_description_line(value: str) -> str:
    for line in value.splitlines():
        line = line.strip()
        if line:
            return line
    return ""


def load_local_channels() -> dict[str, Channel]:
    channels: dict[str, Channel] = {}
    for path in sorted(CABLE_DIR.glob("*.toml")):
        data = tomllib.loads(path.read_text())
        metadata = data.get("metadata", {})
        name = metadata.get("name", path.stem)
        description = first_description_line(metadata.get("description", ""))
        channels[name] = Channel(name=name, description=description, path=path)
    return channels


def group_names(group: str, available: list[str]) -> list[str]:
    if group == "all":
        return [name for name in available if name != "channels"]
    return [name for name in GROUPS[group] if name in available and name != "channels"]


def print_group(group: str) -> int:
    available = available_channel_names()
    local_channels = load_local_channels()
    for name in group_names(group, available):
        channel = local_channels.get(name, Channel(name=name, description=""))
        print(f"{channel.name}\t{channel.description}")
    return 0


def print_local_preview(channel: Channel) -> int:
    if channel.description:
        print(channel.description)
        return 0
    print(channel.name)
    return 0


def print_missing_preview(name: str) -> int:
    print("No local description available.")
    print()
    print("This channel is likely builtin or loaded from another cable directory.")
    return 0


def print_preview(name: str) -> int:
    local_channels = load_local_channels()
    channel = local_channels.get(name)
    if channel:
        return print_local_preview(channel)
    if name in available_channel_names():
        return print_missing_preview(name)
    print(f"Unknown channel: {name}", file=sys.stderr)
    return 1


def usage() -> str:
    return "usage: channel_groups.py list [core|code|infra|tooling|all] | preview CHANNEL"


def main() -> int:
    if len(sys.argv) < 2:
        print(usage(), file=sys.stderr)
        return 1
    if sys.argv[1] == "list":
        group = sys.argv[2] if len(sys.argv) >= 3 else "core"
        if group not in {*GROUPS.keys(), "all"}:
            print(usage(), file=sys.stderr)
            return 1
        return print_group(group)
    if sys.argv[1] == "preview" and len(sys.argv) >= 3:
        return print_preview(sys.argv[2])
    print(usage(), file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

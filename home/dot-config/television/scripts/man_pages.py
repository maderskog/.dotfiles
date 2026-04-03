#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os
import re
import shutil
import signal
import subprocess
import sys


ANSI_RESET = "\033[0m"
ANSI_BOLD_RED = "\033[1;31m"
ANSI_UNDERLINE_GREEN = "\033[1;32;4m"


@dataclass(frozen=True)
class ManPage:
    name: str
    section: str
    description: str


def run_command(command: list[str], env: dict[str, str] | None = None) -> tuple[int, str, str]:
    result = subprocess.run(command, capture_output=True, text=True, errors="replace", env=env)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def has_command(name: str) -> bool:
    return shutil.which(name) is not None


def apropos_command(mode: str) -> list[str] | None:
    section_filter = ["-s", "1:8"] if mode == "commands" else []
    if has_command("apropos"):
        return ["apropos", *section_filter, "."]
    if has_command("man"):
        return ["man", *section_filter, "-k", "."]
    return None


def clean_name(value: str) -> str:
    value = re.sub(r".\x08", "", value)
    value = re.sub(r"\*\[[^]]+\]", "", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def parse_alias(token: str, description: str) -> ManPage | None:
    match = re.match(r"^(?P<name>.+?)\((?P<section>[^)]+)\)$", token.strip())
    if not match:
        return None
    name = clean_name(match.group("name"))
    if not name:
        return None
    return ManPage(name, match.group("section").strip(), description.strip())


def parse_apropos_line(line: str) -> list[ManPage]:
    if " - " not in line:
        return []
    names, description = line.split(" - ", 1)
    pages = []
    for token in names.split(","):
        page = parse_alias(token, description)
        if page:
            pages.append(page)
    return pages


def parse_apropos_output(output: str) -> list[ManPage]:
    pages: dict[tuple[str, str], ManPage] = {}
    for line in output.splitlines():
        for page in parse_apropos_line(line):
            key = (page.name, page.section)
            if key not in pages or (not pages[key].description and page.description):
                pages[key] = page
    return sorted(pages.values(), key=lambda page: (page.name.lower(), page.section.lower()))


def apropos_pages(mode: str) -> list[ManPage]:
    command = apropos_command(mode)
    if not command:
        return []
    _, output, _ = run_command(command)
    return parse_apropos_output(output)


def allowed_section(section: str, mode: str) -> bool:
    if mode != "commands":
        return True
    return section.startswith("1") or section.startswith("8")


def strip_extensions(filename: str) -> str:
    for suffix in (".gz", ".bz2", ".xz", ".lzma", ".zst"):
        if filename.endswith(suffix):
            return filename[: -len(suffix)]
    return filename


def parse_path_page(path: Path, section: str) -> ManPage | None:
    stem = strip_extensions(path.name)
    suffix = f".{section}"
    if not stem.endswith(suffix):
        return None
    name = clean_name(stem[: -len(suffix)])
    if not name:
        return None
    return ManPage(name, section, "")


def man_directories() -> list[Path]:
    code, output, _ = run_command(["manpath"])
    if code != 0 or not output:
        return []
    return [path for path in (Path(value) for value in output.split(":")) if path.is_dir()]


def scan_man_directories(mode: str) -> list[ManPage]:
    pages: dict[tuple[str, str], ManPage] = {}
    for directory in man_directories():
        for man_dir in sorted(directory.glob("man*")):
            if not man_dir.is_dir():
                continue
            section = man_dir.name[3:]
            if not allowed_section(section, mode):
                continue
            for path in sorted(man_dir.iterdir()):
                if not path.is_file():
                    continue
                page = parse_path_page(path, section)
                if page:
                    pages[(page.name, page.section)] = page
    return sorted(pages.values(), key=lambda page: (page.name.lower(), page.section.lower()))


def merge_descriptions(pages: list[ManPage], descriptions: list[ManPage]) -> list[ManPage]:
    description_map = {(page.name, page.section): page.description for page in descriptions}
    merged = []
    for page in pages:
        description = description_map.get((page.name, page.section), "")
        merged.append(ManPage(page.name, page.section, description))
    return merged


def executable_names() -> set[str]:
    names: set[str] = set()
    for directory in os.environ.get("PATH", "").split(os.pathsep):
        if not directory:
            continue
        try:
            with os.scandir(directory) as entries:
                for entry in entries:
                    try:
                        if not entry.is_file():
                            continue
                        if os.access(entry.path, os.X_OK):
                            names.add(entry.name)
                    except OSError:
                        continue
        except OSError:
            continue
    return names


def is_human_command(page: ManPage, names: set[str]) -> bool:
    name = page.name.rsplit("/", 1)[-1]
    if name in names:
        return True
    if "-" not in name:
        return False
    return name.split("-", 1)[0] in names


def load_pages(mode: str) -> list[ManPage]:
    source_mode = "commands" if mode == "human" else mode
    scanned_pages = scan_man_directories(source_mode)
    pages = merge_descriptions(scanned_pages, apropos_pages(source_mode)) if scanned_pages else apropos_pages(source_mode)
    if mode != "human":
        return pages
    names = executable_names()
    return [page for page in pages if is_human_command(page, names)]


def print_list(mode: str) -> int:
    for page in load_pages(mode):
        print(f"{page.name}\t{page.section}")
    return 0


def styled_overstrike(text: str) -> str:
    parts: list[str] = []
    style: str | None = None
    index = 0

    def set_style(next_style: str | None) -> None:
        nonlocal style
        if style == next_style:
            return
        if style is not None:
            parts.append(ANSI_RESET)
        if next_style == "bold":
            parts.append(ANSI_BOLD_RED)
        elif next_style == "underline":
            parts.append(ANSI_UNDERLINE_GREEN)
        style = next_style

    while index < len(text):
        if index + 2 < len(text) and text[index + 1] == "\b":
            first = text[index]
            second = text[index + 2]
            if first == second:
                set_style("bold")
                parts.append(second)
                index += 3
                continue
            if first == "_":
                set_style("underline")
                parts.append(second)
                index += 3
                continue
            if second == "_":
                set_style("underline")
                parts.append(first)
                index += 3
                continue

        if text[index] == "\r":
            index += 1
            continue

        set_style(None)
        parts.append(text[index])
        index += 1

    set_style(None)
    return "".join(parts).strip()


def render_tldr_page(name: str) -> str | None:
    if not has_command("tldr"):
        return None
    code, output, _ = run_command(["tldr", name, "--color", "always"])
    if code != 0 or not output:
        return None
    return output


def render_man_page(name: str, section: str) -> str:
    env = dict(os.environ)
    env["MANPAGER"] = "cat"
    code, output, error = run_command(["man", section, name], env=env)
    text = output if output else error
    if code != 0 and not text:
        return f"No manual entry for {name} ({section})"
    if "\b" in text:
        return styled_overstrike(text)
    if has_command("ul"):
        env["MANPAGER"] = "ul -t xterm-256color"
        env["PAGER"] = "ul -t xterm-256color"
        code, output, error = run_command(["man", section, name], env=env)
        text = output if output else error
        if text:
            return text
        if code != 0:
            return f"No manual entry for {name} ({section})"
    if not has_command("col"):
        return text
    result = subprocess.run(["col", "-bx"], input=text, capture_output=True, text=True, errors="replace")
    cleaned = result.stdout.strip()
    return cleaned or text


def print_preview(name: str, section: str) -> int:
    tldr_page = render_tldr_page(name)
    if tldr_page:
        print(tldr_page)
        return 0
    print(render_man_page(name, section))
    return 0


def usage() -> str:
    return "usage: man_pages.py list [human|commands|all] | preview NAME SECTION"


def main() -> int:
    if len(sys.argv) < 2:
        print(usage(), file=sys.stderr)
        return 1
    if sys.argv[1] == "list":
        mode = sys.argv[2] if len(sys.argv) >= 3 else "human"
        if mode not in {"human", "commands", "all"}:
            print(usage(), file=sys.stderr)
            return 1
        return print_list(mode)
    if sys.argv[1] == "preview" and len(sys.argv) >= 4:
        return print_preview(sys.argv[2], sys.argv[3])
    print(usage(), file=sys.stderr)
    return 1


if __name__ == "__main__":
    if hasattr(signal, "SIGPIPE"):
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    raise SystemExit(main())

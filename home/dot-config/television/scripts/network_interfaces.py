#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import ipaddress
import re
import shutil
import socket
import subprocess
import sys


@dataclass
class Address:
    address: str
    prefix: str | None = None
    netmask: str | None = None
    broadcast: str | None = None


@dataclass
class InterfaceInfo:
    name: str
    platform: str
    flags: list[str] = field(default_factory=list)
    mtu: str | None = None
    status: str | None = None
    mac: str | None = None
    label: str | None = None
    service: str | None = None
    service_order: int | None = None
    hardware_port: str | None = None
    default_gateway: str | None = None
    dns_servers: list[str] = field(default_factory=list)
    search_domains: list[str] = field(default_factory=list)
    ipv4: list[Address] = field(default_factory=list)
    ipv6: list[Address] = field(default_factory=list)
    media: str | None = None
    link_type: str | None = None
    driver: str | None = None
    is_virtual: bool | None = None
    raw_sections: list[tuple[str, str]] = field(default_factory=list)


def run_command(command: list[str]) -> str:
    result = subprocess.run(command, capture_output=True, text=True, errors="replace")
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            ordered.append(value)
    return ordered


def has_command(name: str) -> bool:
    return shutil.which(name) is not None


def strip_peer_suffix(name: str) -> str:
    return name.split("@", 1)[0]


def truncate(text: str, width: int) -> str:
    if len(text) <= width:
        return text
    return text[: width - 1] + "…"


def split_prefix(value: str) -> tuple[str, str | None]:
    if "/" not in value:
        return value, None
    return tuple(value.split("/", 1))


def normalize_ip(value: str) -> str:
    return value.split("%", 1)[0]


def is_link_local(value: str) -> bool:
    try:
        return ipaddress.ip_address(normalize_ip(value)).is_link_local
    except ValueError:
        return False


def interface_state(info: InterfaceInfo) -> str:
    if info.status:
        return info.status.lower()
    if "RUNNING" in info.flags or "LOWER_UP" in info.flags:
        return "running"
    if "UP" in info.flags:
        return "up"
    return "down"


def has_address(info: InterfaceInfo) -> bool:
    return bool(info.ipv4 or info.ipv6)


def format_address(address: Address) -> str:
    if address.prefix:
        return f"{address.address}/{address.prefix}"
    return address.address


def primary_address(info: InterfaceInfo) -> str:
    if info.ipv4:
        return format_address(info.ipv4[0])
    for address in info.ipv6:
        if not is_link_local(address.address):
            return format_address(address)
    if info.ipv6:
        return format_address(info.ipv6[0])
    return "no address"


def gateway_marker(info: InterfaceInfo) -> str:
    if info.default_gateway:
        return "★"
    return " "


def address_marker(info: InterfaceInfo) -> str:
    if has_address(info):
        return "●"
    return "○"


def list_entry(info: InterfaceInfo) -> str:
    label = truncate(info.label or info.name, 22)
    address = truncate(primary_address(info), 30)
    state = truncate(interface_state(info), 8)
    display = f"{gateway_marker(info)} {address_marker(info)} {info.name:<8} {state:<8} {label:<22} {address}"
    return f"{info.name}\t{display}"


def sort_key(info: InterfaceInfo) -> tuple[int, int, int, str]:
    default_rank = 0 if info.default_gateway else 1
    active_rank = 0 if interface_state(info) == "active" else 1
    addressed_rank = 0 if has_address(info) else 1
    return default_rank, active_rank, addressed_rank, info.name


def address_lines(label: str, addresses: list[Address], include_broadcast: bool = False) -> list[str]:
    if not addresses:
        return []
    values: list[str] = []
    for address in addresses:
        text = format_address(address)
        if include_broadcast and address.broadcast:
            text = f"{text} (broadcast {address.broadcast})"
        values.append(text)
    lines = [f"{label:<14} {values[0]}"]
    lines.extend(f"{'':<14} {value}" for value in values[1:])
    return lines


def detail_lines(info: InterfaceInfo) -> list[str]:
    lines = [
        f"{'Interface':<14} {info.name}",
        f"{'Label':<14} {info.label or info.name}",
    ]
    if info.service:
        service = info.service
        if info.service_order:
            service = f"{service} (#{info.service_order})"
        lines.append(f"{'Service':<14} {service}")
    if info.hardware_port:
        lines.append(f"{'Hardware Port':<14} {info.hardware_port}")
    try:
        lines.append(f"{'Index':<14} {socket.if_nametoindex(info.name)}")
    except OSError:
        pass
    default_route = "no"
    if info.default_gateway:
        default_route = f"yes via {info.default_gateway}"
    lines.append(f"{'Default Route':<14} {default_route}")
    lines.append(f"{'Has Address':<14} {'yes' if has_address(info) else 'no'}")
    lines.append(f"{'Status':<14} {interface_state(info)}")
    if info.flags:
        lines.append(f"{'Flags':<14} {', '.join(info.flags)}")
    if info.mtu:
        lines.append(f"{'MTU':<14} {info.mtu}")
    if info.mac:
        lines.append(f"{'MAC':<14} {info.mac}")
    if info.media:
        lines.append(f"{'Media':<14} {info.media}")
    if info.link_type:
        lines.append(f"{'Link Type':<14} {info.link_type}")
    if info.driver:
        lines.append(f"{'Driver':<14} {info.driver}")
    if info.is_virtual is not None:
        lines.append(f"{'Virtual':<14} {'yes' if info.is_virtual else 'no'}")
    lines.extend(address_lines("IPv4", info.ipv4, include_broadcast=True))
    lines.extend(address_lines("IPv6", info.ipv6))
    if info.dns_servers:
        lines.append(f"{'DNS':<14} {', '.join(info.dns_servers)}")
    if info.search_domains:
        lines.append(f"{'Search':<14} {', '.join(info.search_domains)}")
    return lines


def preview_text(info: InterfaceInfo) -> str:
    lines = detail_lines(info)
    for title, content in info.raw_sections:
        if not content:
            continue
        lines.extend(["", title, "-" * len(title), content])
    return "\n".join(lines)


def platform_name() -> str | None:
    if sys.platform == "darwin":
        return "darwin"
    if sys.platform.startswith("linux"):
        return "linux"
    return None


def load_interfaces(mode: str) -> list[InterfaceInfo]:
    platform = platform_name()
    if platform == "darwin":
        interfaces = load_macos_interfaces()
    elif platform == "linux":
        interfaces = load_linux_interfaces()
    else:
        return []
    if mode == "physical":
        interfaces = [info for info in interfaces if is_physical_interface(info)]
    return sorted(interfaces, key=sort_key)


def load_interface(name: str) -> InterfaceInfo | None:
    for info in load_interfaces("all"):
        if info.name == name:
            return info
    return None


def is_physical_interface(info: InterfaceInfo) -> bool:
    if info.platform == "darwin":
        return is_physical_macos(info)
    return is_physical_linux(info)


def is_physical_macos(info: InterfaceInfo) -> bool:
    noisy_prefixes = ("utun", "awdl", "llw", "anpi", "gif", "stf")
    if info.name.startswith(noisy_prefixes):
        return False
    if info.name.startswith("ap") or info.name == "lo0":
        return False
    if info.hardware_port:
        return True
    return info.name.startswith(("en", "bridge"))


def is_physical_linux(info: InterfaceInfo) -> bool:
    noisy_prefixes = ("lo", "tun", "tap", "tailscale", "wg", "docker", "veth", "virbr", "ifb", "dummy")
    if info.name.startswith(noisy_prefixes):
        return False
    if info.is_virtual is False:
        return True
    return info.name.startswith(("eth", "en", "wl", "ww"))


def macos_label(name: str, hardware_port: str | None, service: str | None) -> str:
    if service and not service.isdigit():
        return service
    if hardware_port:
        return hardware_port
    if name.startswith("lo"):
        return "Loopback"
    if name.startswith(("utun", "gif", "stf")):
        return "Tunnel"
    if name.startswith("bridge"):
        return "Bridge"
    if name.startswith("awdl"):
        return "AWDL"
    if name.startswith("llw"):
        return "Low Latency Wi-Fi"
    if name.startswith("ap"):
        return "Access Point"
    if name.startswith("en"):
        return "Ethernet"
    return "Interface"


def netmask_to_prefix(netmask: str | None) -> str | None:
    if not netmask:
        return None
    if netmask.startswith("0x"):
        mask_value = int(netmask, 16)
    else:
        mask_value = int(ipaddress.IPv4Address(netmask))
    return str(bin(mask_value).count("1"))


def parse_macos_ifconfig(name: str, raw_output: str) -> InterfaceInfo:
    info = InterfaceInfo(name=name, platform="darwin")
    lines = raw_output.splitlines()
    if lines:
        header = re.match(r"^\S+: flags=\d+<([^>]*)> mtu (\d+)$", lines[0])
        if header:
            info.flags = [flag for flag in header.group(1).split(",") if flag]
            info.mtu = header.group(2)
    for raw_line in lines[1:]:
        line = raw_line.strip()
        if line.startswith("ether "):
            info.mac = line.split()[1]
        elif line.startswith("status: "):
            info.status = line.split(":", 1)[1].strip()
        elif line.startswith("media: "):
            info.media = line.split(":", 1)[1].strip()
        elif line.startswith("inet "):
            info.ipv4.append(parse_macos_ipv4(line))
        elif line.startswith("inet6 "):
            info.ipv6.append(parse_macos_ipv6(line))
    return info


def parse_macos_ipv4(line: str) -> Address:
    parts = line.split()
    netmask = parts[parts.index("netmask") + 1] if "netmask" in parts else None
    broadcast = parts[parts.index("broadcast") + 1] if "broadcast" in parts else None
    return Address(parts[1], netmask_to_prefix(netmask), netmask, broadcast)


def parse_macos_ipv6(line: str) -> Address:
    parts = line.split()
    prefix = parts[parts.index("prefixlen") + 1] if "prefixlen" in parts else None
    return Address(parts[1], prefix)


def parse_hardware_ports(raw_output: str) -> dict[str, dict[str, str]]:
    mapping: dict[str, dict[str, str]] = {}
    current: dict[str, str] = {}
    for line in raw_output.splitlines():
        stripped = line.strip()
        if not stripped:
            if current.get("device"):
                mapping[current["device"]] = dict(current)
            current = {}
            continue
        if stripped.startswith("Hardware Port: "):
            current["hardware_port"] = stripped.split(":", 1)[1].strip()
        elif stripped.startswith("Device: "):
            current["device"] = stripped.split(":", 1)[1].strip()
    if current.get("device"):
        mapping[current["device"]] = dict(current)
    return mapping


def parse_service_order(raw_output: str) -> dict[str, dict[str, str | int]]:
    mapping: dict[str, dict[str, str | int]] = {}
    service_name: str | None = None
    service_order: int | None = None
    numbered_line = re.compile(r"^\((\d+)\)\s+(.*)$")
    device_line = re.compile(r"^\(Hardware Port: .*?, Device: (.*?)\)$")
    for line in raw_output.splitlines():
        numbered = numbered_line.match(line.strip())
        if numbered:
            service_order = int(numbered.group(1))
            service_name = numbered.group(2).strip()
            continue
        device = device_line.match(line.strip())
        if device and service_name and device.group(1):
            mapping[device.group(1)] = {"service": service_name, "order": service_order or 0}
    return mapping


def parse_default_route(raw_output: str) -> tuple[str | None, str | None]:
    interface = None
    gateway = None
    for line in raw_output.splitlines():
        stripped = line.strip()
        if stripped.startswith("interface:"):
            interface = stripped.split(":", 1)[1].strip()
        elif stripped.startswith("gateway:"):
            gateway = stripped.split(":", 1)[1].strip()
    return interface, gateway


def parse_macos_dns(raw_output: str) -> dict[str, dict[str, list[str]]]:
    mapping: dict[str, dict[str, list[str]]] = {}
    resolver = {"interface": None, "nameservers": [], "search_domains": []}
    for line in raw_output.splitlines():
        stripped = line.strip()
        if stripped.startswith("resolver #"):
            flush_macos_dns(mapping, resolver)
            resolver = {"interface": None, "nameservers": [], "search_domains": []}
            continue
        if stripped.startswith("nameserver["):
            resolver["nameservers"].append(stripped.split(":", 1)[1].strip())
        elif stripped.startswith("search domain["):
            resolver["search_domains"].append(stripped.split(":", 1)[1].strip())
        elif stripped.startswith("domain   :"):
            resolver["search_domains"].append(stripped.split(":", 1)[1].strip().rstrip("."))
        else:
            match = re.search(r"if_index\s*:\s*\d+\s+\(([^)]+)\)", stripped)
            if match:
                resolver["interface"] = match.group(1)
    flush_macos_dns(mapping, resolver)
    return mapping


def flush_macos_dns(mapping: dict[str, dict[str, list[str]]], resolver: dict[str, object]) -> None:
    interface = resolver.get("interface")
    if not interface:
        return
    current = mapping.setdefault(interface, {"nameservers": [], "search_domains": []})
    current["nameservers"] = unique(current["nameservers"] + resolver["nameservers"])
    current["search_domains"] = unique(current["search_domains"] + resolver["search_domains"])


def load_macos_interfaces() -> list[InterfaceInfo]:
    names = [name for name in run_command(["ifconfig", "-l"]).split() if name]
    hardware_ports = parse_hardware_ports(run_command(["networksetup", "-listallhardwareports"]))
    service_order = parse_service_order(run_command(["networksetup", "-listnetworkserviceorder"]))
    default_interface, default_gateway = parse_default_route(run_command(["route", "-n", "get", "default"]))
    dns_mapping = parse_macos_dns(run_command(["scutil", "--dns"]))
    interfaces: list[InterfaceInfo] = []
    for name in names:
        raw_ifconfig = run_command(["ifconfig", name])
        if not raw_ifconfig:
            continue
        info = parse_macos_ifconfig(name, raw_ifconfig)
        hardware = hardware_ports.get(name, {})
        service = service_order.get(name, {})
        dns = dns_mapping.get(name, {"nameservers": [], "search_domains": []})
        info.hardware_port = hardware.get("hardware_port")
        info.service = service.get("service")
        info.service_order = service.get("order")
        info.label = macos_label(name, info.hardware_port, info.service)
        info.dns_servers = dns.get("nameservers", [])
        info.search_domains = dns.get("search_domains", [])
        if name == default_interface:
            info.default_gateway = default_gateway
        info.raw_sections.append(("ifconfig", raw_ifconfig))
        if info.service:
            service_info = run_command(["networksetup", "-getinfo", str(info.service)])
            if service_info:
                title = f"networksetup -getinfo {info.service}"
                info.raw_sections.append((title, service_info))
        interfaces.append(info)
    return interfaces


def infer_linux_label(name: str) -> str:
    if name == "lo":
        return "Loopback"
    if name.startswith(("wl", "wlan")):
        return "Wi-Fi"
    if name.startswith(("ww", "wwan")):
        return "WWAN"
    if name.startswith(("eth", "en")):
        return "Ethernet"
    if name.startswith(("br", "virbr")):
        return "Bridge"
    if name.startswith(("docker", "veth")):
        return "Container Network"
    if name.startswith(("tun", "tap", "wg", "tailscale")):
        return "Tunnel"
    return "Interface"


def parse_linux_links(raw_output: str) -> dict[str, InterfaceInfo]:
    interfaces: dict[str, InterfaceInfo] = {}
    for line in raw_output.splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue
        name = strip_peer_suffix(parts[1].rstrip(":"))
        info = InterfaceInfo(name=name, platform="linux")
        flags = re.search(r"<([^>]*)>", line)
        link = re.search(r"link/(\S+)\s+([^\s]+)", line)
        info.flags = flags.group(1).split(",") if flags else []
        info.mtu = parts[parts.index("mtu") + 1] if "mtu" in parts else None
        info.status = parts[parts.index("state") + 1] if "state" in parts else None
        if link:
            info.link_type = link.group(1)
            if re.match(r"^[0-9a-fA-F:]+$", link.group(2)):
                info.mac = link.group(2)
        interfaces[name] = info
    return interfaces


def parse_linux_addresses(raw_output: str, family: str) -> dict[str, list[Address]]:
    mapping: dict[str, list[Address]] = {}
    for line in raw_output.splitlines():
        parts = line.split()
        if len(parts) < 4:
            continue
        name = strip_peer_suffix(parts[1])
        value, prefix = split_prefix(parts[3])
        address = Address(value, prefix)
        if family == "ipv4" and "brd" in parts:
            address.broadcast = parts[parts.index("brd") + 1]
        mapping.setdefault(name, []).append(address)
    return mapping


def parse_linux_default_routes(raw_output: str) -> dict[str, str]:
    routes: dict[str, str] = {}
    for line in raw_output.splitlines():
        parts = line.split()
        if "dev" not in parts:
            continue
        name = parts[parts.index("dev") + 1]
        gateway = parts[parts.index("via") + 1] if "via" in parts else "default"
        routes[name] = gateway
    return routes


def parse_resolvectl_values(raw_output: str) -> tuple[dict[str, list[str]], list[str]]:
    per_interface: dict[str, list[str]] = {}
    global_values: list[str] = []
    for line in raw_output.splitlines():
        stripped = line.strip()
        if ":" not in stripped:
            continue
        left, right = stripped.split(":", 1)
        values = right.strip().split()
        if left == "Global":
            global_values.extend(values)
            continue
        match = re.match(r"Link \d+ \(([^)]+)\)", left)
        if match:
            per_interface.setdefault(match.group(1), []).extend(values)
    cleaned = {name: unique(values) for name, values in per_interface.items()}
    return cleaned, unique(global_values)


def parse_resolv_conf() -> dict[str, list[str]]:
    path = Path("/etc/resolv.conf")
    if not path.exists():
        return {"nameservers": [], "search_domains": []}
    nameservers: list[str] = []
    search_domains: list[str] = []
    for line in path.read_text(errors="replace").splitlines():
        stripped = line.split("#", 1)[0].strip()
        if stripped.startswith("nameserver "):
            nameservers.append(stripped.split()[1])
        elif stripped.startswith("search "):
            search_domains.extend(stripped.split()[1:])
        elif stripped.startswith("domain "):
            search_domains.append(stripped.split()[1])
    return {
        "nameservers": unique(nameservers),
        "search_domains": unique(search_domains),
    }


def load_linux_dns(names: list[str]) -> dict[str, dict[str, list[str]]]:
    if has_command("resolvectl"):
        dns_values, global_dns = parse_resolvectl_values(run_command(["resolvectl", "dns"]))
        domain_values, global_domains = parse_resolvectl_values(run_command(["resolvectl", "domain"]))
        mapping: dict[str, dict[str, list[str]]] = {}
        for name in names:
            mapping[name] = {
                "nameservers": unique(dns_values.get(name, []) + global_dns),
                "search_domains": unique(domain_values.get(name, []) + global_domains),
            }
        return mapping
    fallback = parse_resolv_conf()
    return {name: dict(fallback) for name in names}


def linux_driver(name: str) -> str | None:
    path = Path("/sys/class/net") / name / "device" / "driver"
    if not path.exists():
        return None
    return path.resolve().name


def linux_is_virtual(name: str) -> bool | None:
    path = Path("/sys/class/net") / name
    if not path.exists():
        return None
    return "/virtual/" in str(path.resolve())


def linux_label(name: str) -> str:
    if (Path("/sys/class/net") / name / "wireless").exists():
        return "Wi-Fi"
    return infer_linux_label(name)


def load_linux_interfaces() -> list[InterfaceInfo]:
    interfaces = parse_linux_links(run_command(["ip", "-o", "link", "show"]))
    ipv4 = parse_linux_addresses(run_command(["ip", "-o", "-4", "addr", "show"]), "ipv4")
    ipv6 = parse_linux_addresses(run_command(["ip", "-o", "-6", "addr", "show"]), "ipv6")
    routes = parse_linux_default_routes(run_command(["ip", "route", "show", "default"]))
    dns_mapping = load_linux_dns(list(interfaces))
    for name, info in interfaces.items():
        info.ipv4 = ipv4.get(name, [])
        info.ipv6 = ipv6.get(name, [])
        info.default_gateway = routes.get(name)
        info.dns_servers = dns_mapping.get(name, {}).get("nameservers", [])
        info.search_domains = dns_mapping.get(name, {}).get("search_domains", [])
        info.label = linux_label(name)
        info.driver = linux_driver(name)
        info.is_virtual = linux_is_virtual(name)
        info.raw_sections = linux_raw_sections(name)
    return list(interfaces.values())


def linux_raw_sections(name: str) -> list[tuple[str, str]]:
    sections = [
        (f"ip address show dev {name}", run_command(["ip", "address", "show", "dev", name])),
        (f"ip route show dev {name}", run_command(["ip", "route", "show", "dev", name])),
    ]
    if has_command("resolvectl"):
        sections.append((f"resolvectl status {name}", run_command(["resolvectl", "status", name])))
    return sections


def print_list(mode: str) -> int:
    for info in load_interfaces(mode):
        print(list_entry(info))
    return 0


def print_preview(name: str) -> int:
    info = load_interface(name)
    if not info:
        print(f"Unknown interface: {name}", file=sys.stderr)
        return 1
    print(preview_text(info))
    return 0


def usage() -> str:
    return "usage: network_interfaces.py list [physical|all] | preview INTERFACE"


def main() -> int:
    if not platform_name():
        print("network-interfaces supports macOS and Linux", file=sys.stderr)
        return 1
    if len(sys.argv) < 2:
        print(usage(), file=sys.stderr)
        return 1
    if sys.argv[1] == "list":
        mode = sys.argv[2] if len(sys.argv) >= 3 else "physical"
        if mode not in {"physical", "all"}:
            print(usage(), file=sys.stderr)
            return 1
        return print_list(mode)
    if sys.argv[1] == "preview" and len(sys.argv) >= 3:
        return print_preview(sys.argv[2])
    print(usage(), file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

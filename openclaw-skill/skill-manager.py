#!/usr/bin/env python3
"""
CLI-Anything Native Skill Manager
Helper script for managing the skill, virtual environment, and CLI wrappers.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def get_skill_dir():
    """Get the skill installation directory."""
    return Path.home() / ".openclaw" / "workspace" / "skills" / "cli-anything-native"


def get_local_bin():
    """Get the user local bin directory."""
    return Path.home() / ".local" / "bin"


def get_config():
    """Read skill configuration."""
    config_file = get_skill_dir() / "skill-config.json"
    if config_file.exists():
        with open(config_file) as f:
            return json.load(f)
    return None


def get_venv_path():
    """Get the virtual environment path."""
    # Default: skill-dir/.venv
    default_venv = get_skill_dir() / ".venv"
    
    # Check config
    config = get_config()
    if config and "venv_path" in config:
        venv_path = Path(config["venv_path"])
        if venv_path.exists():
            return venv_path
    
    return default_venv if default_venv.exists() else None


def has_uv():
    """Check if uv is available."""
    return subprocess.run(["which", "uv"], capture_output=True).returncode == 0


def get_package_manager():
    """Get the package manager (uv or pip)."""
    config = get_config()
    if config and config.get("use_uv", False):
        return "uv"
    return "pip"


def get_cli_commands():
    """Get list of available cli-anything-* commands in venv."""
    venv_path = get_venv_path()
    if not venv_path:
        return []
    
    bin_dir = venv_path / "bin"
    if not bin_dir.exists():
        return []
    
    commands = []
    for cmd in bin_dir.glob("cli-anything-*"):
        if cmd.is_file():
            commands.append(cmd.name)
    return sorted(commands)


def create_wrapper(cmd_name):
    """Create a wrapper script for a CLI command."""
    venv_path = get_venv_path()
    local_bin = get_local_bin()
    
    if not venv_path:
        print("Error: Virtual environment not found", file=sys.stderr)
        return False
    
    wrapper_path = local_bin / cmd_name
    
    wrapper_content = f'''#!/bin/bash
# Auto-generated wrapper for {cmd_name}
# Source: CLI-Anything Native Skill
# Venv: {venv_path}

export PATH="{venv_path}/bin:$PATH"
export VIRTUAL_ENV="{venv_path}"

if [ ! -f "{venv_path}/bin/{cmd_name}" ]; then
    echo "Error: {cmd_name} not found in virtual environment" >&2
    echo "Please reinstall the skill: ./install.sh" >&2
    exit 1
fi

exec "{venv_path}/bin/{cmd_name}" "$@"
'''
    
    wrapper_path.write_text(wrapper_content)
    wrapper_path.chmod(0o755)
    return True


def remove_wrapper(cmd_name):
    """Remove a wrapper script."""
    local_bin = get_local_bin()
    wrapper_path = local_bin / cmd_name
    
    if wrapper_path.exists():
        # Check if it's our wrapper
        try:
            content = wrapper_path.read_text()
            if "CLI-Anything Native Skill" in content:
                wrapper_path.unlink()
                return True
        except Exception:
            pass
    return False


def link_commands():
    """Create wrapper scripts for all cli-anything-* commands."""
    commands = get_cli_commands()
    if not commands:
        print("No cli-anything-* commands found in venv.")
        print("Build some CLIs first using the skill!")
        return 0
    
    local_bin = get_local_bin()
    local_bin.mkdir(parents=True, exist_ok=True)
    
    print(f"Creating wrapper scripts in {local_bin}...")
    created = 0
    skipped = 0
    
    for cmd in commands:
        wrapper_path = local_bin / cmd
        if wrapper_path.exists():
            # Check if it's our wrapper
            try:
                content = wrapper_path.read_text()
                if "CLI-Anything Native Skill" in content:
                    print(f"  ✓ {cmd} (already exists)")
                    skipped += 1
                    continue
                else:
                    print(f"  ⚠️  {cmd} (exists but not ours, skipping)")
                    continue
            except Exception:
                print(f"  ⚠️  {cmd} (cannot read, skipping)")
                continue
        
        if create_wrapper(cmd):
            print(f"  ✅ {cmd}")
            created += 1
        else:
            print(f"  ❌ {cmd}")
    
    print(f"\nSummary: {created} created, {skipped} already existed")
    
    # Check PATH
    path_str = os.environ.get("PATH", "")
    if str(local_bin) not in path_str:
        print(f"\n⚠️  Warning: {local_bin} is not in your PATH")
        print("Add this to your shell config:")
        print(f'  export PATH="$HOME/.local/bin:$PATH"')
    
    return 0


def unlink_commands():
    """Remove all cli-anything-* wrapper scripts."""
    local_bin = get_local_bin()
    
    if not local_bin.exists():
        print(f"{local_bin} does not exist")
        return 0
    
    print(f"Removing wrapper scripts from {local_bin}...")
    removed = 0
    not_found = 0
    
    for cmd in get_cli_commands():
        wrapper_path = local_bin / cmd
        if wrapper_path.exists():
            if remove_wrapper(cmd):
                print(f"  ✅ Removed: {cmd}")
                removed += 1
            else:
                print(f"  ⚠️  Skipped: {cmd} (not ours)")
        else:
            not_found += 1
    
    print(f"\nSummary: {removed} removed")
    return 0


def activate_venv():
    """Print activation command for the venv."""
    venv_path = get_venv_path()
    if venv_path and venv_path.exists():
        activate_script = venv_path / "bin" / "activate"
        print(f"source {activate_script}")
        return 0
    else:
        print(f"Virtual environment not found", file=sys.stderr)
        print("Run ./install.sh first to create the venv.", file=sys.stderr)
        return 1


def get_python_path():
    """Get the Python interpreter path in venv."""
    venv_path = get_venv_path()
    if venv_path:
        python_path = venv_path / "bin" / "python3"
        if python_path.exists():
            return python_path
    return None


def run_in_venv(command, use_uv=None):
    """Run a command in the virtual environment."""
    python_path = get_python_path()
    if not python_path:
        print("Virtual environment not found. Run ./install.sh first.", file=sys.stderr)
        return 1
    
    env = os.environ.copy()
    env["PATH"] = str(python_path.parent) + ":" + env.get("PATH", "")
    env["VIRTUAL_ENV"] = str(get_venv_path())
    
    # Check if we should use uv
    if use_uv is None:
        use_uv = has_uv() and get_package_manager() == "uv"
    
    if use_uv and has_uv():
        # Use uv for the command if it's a pip command
        if command.startswith("pip "):
            command = "uv " + command[4:]
        elif command.startswith("python3 -m pip "):
            command = "uv " + command[15:]
    
    result = subprocess.run(command, shell=True, env=env)
    return result.returncode


def install_packages(*packages):
    """Install packages in the virtual environment."""
    if has_uv() and get_package_manager() == "uv":
        venv_path = get_venv_path()
        cmd = f"uv pip install --python {venv_path}/bin/python {' '.join(packages)}"
    else:
        python_path = get_python_path()
        cmd = f"{python_path} -m pip install {' '.join(packages)}"
    
    return run_in_venv(cmd)


def show_status():
    """Show skill status."""
    print("CLI-Anything Native Skill Status")
    print("=" * 60)
    
    skill_dir = get_skill_dir()
    print(f"Skill directory: {skill_dir}")
    print(f"Skill exists: {skill_dir.exists()}")
    
    config = get_config()
    if config:
        print(f"\nConfiguration:")
        for key, value in config.items():
            if key == "install_date":
                print(f"  {key}: {value}")
            else:
                print(f"  {key}: {value}")
    
    # Check uv availability
    print(f"\nPackage Manager:")
    print(f"  uv available: {has_uv()}")
    if config:
        print(f"  Configured to use: {get_package_manager()}")
    
    venv_path = get_venv_path()
    if venv_path:
        print(f"\nVirtual environment:")
        print(f"  Path: {venv_path}")
        print(f"  Exists: {venv_path.exists()}")
        
        if venv_path.exists():
            python_path = venv_path / "bin" / "python3"
            print(f"  Python: {python_path}")
            print(f"  Python exists: {python_path.exists()}")
            
            if python_path.exists():
                # Get Python version
                result = subprocess.run(
                    [str(python_path), "--version"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    print(f"  Version: {result.stdout.strip()}")
            
            # List CLI commands
            commands = get_cli_commands()
            if commands:
                print(f"\nInstalled CLI tools ({len(commands)}):")
                for cmd in commands[:10]:  # Show first 10
                    print(f"    - {cmd}")
                if len(commands) > 10:
                    print(f"    ... and {len(commands) - 10} more")
            else:
                print(f"\nNo CLI tools installed yet")
                print("  Run: cli-anything-build <software> to create one")
    else:
        print("\nVirtual environment: Not configured")
    
    # Check wrappers
    local_bin = get_local_bin()
    if local_bin.exists():
        wrappers = list(local_bin.glob("cli-anything-*"))
        our_wrappers = []
        for w in wrappers:
            try:
                content = w.read_text()
                if "CLI-Anything Native Skill" in content:
                    our_wrappers.append(w.name)
            except Exception:
                pass
        
        if our_wrappers:
            print(f"\nWrapper scripts in {local_bin}:")
            for w in our_wrappers[:10]:
                print(f"    - {w}")
            if len(our_wrappers) > 10:
                print(f"    ... and {len(our_wrappers) - 10} more")
        else:
            print(f"\nNo wrapper scripts found in {local_bin}")
            print("  Run: skill-manager link")
    
    # Check PATH
    path_str = os.environ.get("PATH", "")
    if str(local_bin) not in path_str:
        print(f"\n⚠️  Warning: {local_bin} is not in your PATH")
        print("  Add this to your shell config:")
        print(f'    export PATH="$HOME/.local/bin:$PATH"')
    
    return 0


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: skill-manager <command>")
        print("")
        print("Commands:")
        print("  status          Show skill and venv status")
        print("  activate        Print venv activation command")
        print("  python          Print path to venv Python")
        print("  run <cmd>       Run command in venv")
        print("  install <pkg>   Install package in venv")
        print("  link            Create wrapper scripts in ~/.local/bin")
        print("  unlink          Remove wrapper scripts from ~/.local/bin")
        print("")
        print("Environment:")
        print(f"  uv available: {has_uv()}")
        config = get_config()
        if config:
            print(f"  Using: {get_package_manager()}")
        return 1
    
    command = sys.argv[1]
    
    if command == "status":
        return show_status()
    elif command == "activate":
        return activate_venv()
    elif command == "python":
        python_path = get_python_path()
        if python_path:
            print(python_path)
            return 0
        else:
            print("Python not found in venv", file=sys.stderr)
            return 1
    elif command == "run":
        if len(sys.argv) < 3:
            print("Usage: skill-manager run <command>", file=sys.stderr)
            return 1
        return run_in_venv(" ".join(sys.argv[2:]))
    elif command == "install":
        if len(sys.argv) < 3:
            print("Usage: skill-manager install <package>", file=sys.stderr)
            return 1
        return install_packages(*sys.argv[2:])
    elif command == "link":
        return link_commands()
    elif command == "unlink":
        return unlink_commands()
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

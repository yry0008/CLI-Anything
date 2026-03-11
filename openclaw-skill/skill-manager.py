#!/usr/bin/env python3
"""
CLI-Anything Native Skill Manager
Helper script for managing the skill and virtual environment.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def get_skill_dir():
    """Get the skill installation directory."""
    return Path.home() / ".openclaw" / "workspace" / "skills" / "cli-anything-native"


def get_config():
    """Read skill configuration."""
    config_file = get_skill_dir() / "skill-config.json"
    if config_file.exists():
        with open(config_file) as f:
            return json.load(f)
    return None


def get_venv_path():
    """Get the virtual environment path."""
    config = get_config()
    if config and "venv_path" in config:
        return Path(config["venv_path"])
    
    # Try to find venv in CLI-Anything repo
    skill_dir = get_skill_dir()
    repo_dir = skill_dir.parent.parent.parent  # skills/ -> workspace/ -> .openclaw/ -> home
    venv_path = repo_dir / "CLI-Anything" / ".venv"
    if venv_path.exists():
        return venv_path
    
    return None


def activate_venv():
    """Print activation command for the venv."""
    venv_path = get_venv_path()
    if venv_path and venv_path.exists():
        activate_script = venv_path / "bin" / "activate"
        print(f"source {activate_script}")
        return 0
    else:
        print(f"Virtual environment not found at: {venv_path}", file=sys.stderr)
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


def run_in_venv(command):
    """Run a command in the virtual environment."""
    python_path = get_python_path()
    if not python_path:
        print("Virtual environment not found. Run ./install.sh first.", file=sys.stderr)
        return 1
    
    env = os.environ.copy()
    env["PATH"] = str(python_path.parent) + ":" + env.get("PATH", "")
    env["VIRTUAL_ENV"] = str(get_venv_path())
    
    result = subprocess.run(command, shell=True, env=env)
    return result.returncode


def show_status():
    """Show skill status."""
    print("CLI-Anything Native Skill Status")
    print("=" * 50)
    
    skill_dir = get_skill_dir()
    print(f"Skill directory: {skill_dir}")
    print(f"Skill exists: {skill_dir.exists()}")
    
    config = get_config()
    if config:
        print(f"\nConfiguration:")
        for key, value in config.items():
            print(f"  {key}: {value}")
    
    venv_path = get_venv_path()
    if venv_path:
        print(f"\nVirtual environment:")
        print(f"  Path: {venv_path}")
        print(f"  Exists: {venv_path.exists()}")
        
        if venv_path.exists():
            python_path = venv_path / "bin" / "python3"
            print(f"  Python: {python_path}")
            print(f"  Python exists: {python_path.exists()}")
            
            # Check installed packages
            result = subprocess.run(
                [str(python_path), "-m", "pip", "list"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                print(f"\nInstalled packages (venv):")
                for line in result.stdout.split("\n")[2:10]:  # Show first few packages
                    if line.strip():
                        print(f"    {line}")
    else:
        print("\nVirtual environment: Not configured")
    
    return 0


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: skill-manager <command>")
        print("")
        print("Commands:")
        print("  status      Show skill and venv status")
        print("  activate    Print venv activation command")
        print("  python      Print path to venv Python")
        print("  run <cmd>   Run command in venv")
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
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

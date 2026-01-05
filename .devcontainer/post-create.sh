#!/bin/bash

set -e

echo "=========================================="
echo "Setting up Ada BB-Runtimes Dev Environment"
echo "=========================================="

# Set up user shell environment
echo ""
echo "Configuring shell environment..."
echo "--------------------------------"
if [ -d "$HOME" ]; then
    # Add PATH configuration to bashrc if not already present
    if ! grep -q "export PATH.*arm-toolchain" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:/opt/arm-toolchain/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PS1="\[\033[01;32m\]\u@ada-dev\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> "$HOME/.bashrc"
    fi
    
    # Create alire config directory
    mkdir -p "$HOME/.config/alire"
fi

# Initialize Alire in the workspace
echo ""
echo "Initializing Alire..."
echo "---------------------"
cd /workspace

# Check if alire.toml exists
if [ -f "alire.toml" ]; then
    echo "Found alire.toml, setting up Alire environment..."
    
    # Initialize Alire (this will download and setup GNAT toolchain)
    alr toolchain --select gnat_native gprbuild
    
    echo "Alire toolchain configured successfully!"
else
    echo "Warning: alire.toml not found. Skipping Alire setup."
fi

# Display versions
echo ""
echo "Installed toolchain versions:"
echo "----------------------------"
echo "Alire: $(alr version)"
alr exec -- gnat --version 2>/dev/null || gnat --version || echo "GNAT: not found in PATH"
arm-none-eabi-gcc --version | head -n1 || echo "ARM GCC: not found"
python --version || echo "Python: not found"
alr exec -- gprbuild --version 2>/dev/null | head -n1 || gprbuild --version 2>/dev/null | head -n1 || echo "GPRbuild: not found"

echo ""
echo "Python packages:"
echo "----------------"
pip3 list | grep -E "(pyyaml|jinja2|pyelftools|intelhex)" || echo "No required packages found"

echo ""
echo "=========================================="
echo "Setup complete!"
echo ""
echo "Quick start:"
echo "  - Run commands with Alire: alr exec -- <command>"
echo "  - Build runtime: alr exec -- python build_rts.py --output=build <board>"
echo "  - List available boards: python build_rts.py --list"
echo "  - For STM32H7 development, check: arm/stm32/"
echo ""
echo "Note: All GNAT toolchain commands should be run via 'alr exec --'"
echo "=========================================="

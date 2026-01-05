# Ada BB-Runtimes Development Container

This devcontainer provides a complete development environment for working with Ada bare-metal runtimes, specifically configured for STM32H7 development.

## What's Included

### Toolchains
- **Alire**: Ada package manager for toolchain management
- **GNAT**: Ada compiler (managed via Alire)
- **GPRbuild**: Build tool for Ada projects (managed via Alire)
- **ARM GCC 13.3**: ARM bare-metal cross-compiler (`arm-none-eabi-gcc`)
- **GDB Multiarch**: Debugger with support for multiple architectures
- **OpenOCD**: On-chip debugging tool

### Development Tools
- Python 3 with required packages:
  - PyYAML
  - Jinja2
  - pyelftools
  - intelhex
- Git & Git LFS
- Build essentials (make, cmake, etc.)

### VS Code Extensions
- AdaCore Ada Language Support
- Python support with Pylance

## Quick Start

1. **Open in Container**
   - Open this folder in VS Code
   - Click "Reopen in Container" when prompted
   - Or use Command Palette: `Remote-Containers: Reopen in Container`

2. **List Available Boards**
   ```bash
   python build_rts.py --list
   ```

3. **Build a Runtime**
   ```bash
   # All Ada toolchain commands should use Alire
   alr exec -- python build_rts.py --output=build <board-name>
   ```

4. **For STM32H7 Development**
   - Check existing STM32 boards in `arm/stm32/`
   - Use similar boards as reference for STM32H7

## Development Workflow

### Building Runtimes
```bash
# Build for a specific board (use Alire to ensure correct toolchain)
alr exec -- python build_rts.py --output=build stm32f4

# Build with verbose output
alr exec -- python build_rts.py --verbose --output=build <board>

# Install built runtime
alr exec -- python install.py <build-dir>

# Use gprbuild directly
alr exec -- gprbuild -P <project-file>
```

### Creating New Board Support

1. Create board configuration in `arm/stm32/`
2. Define memory layout and peripherals
3. Configure runtime profile (zero footprint, embedded, etc.)
4. Build and test

## Toolchain Management with Alire

This project uses Alire to manage GNAT toolchains. All Ada compilation commands should be run via:

```bash
alr exec -- <command>
```

### Toolchain Paths

- **Alire**: `/usr/local/bin/alr`
- **GNAT**: Managed by Alire (use `alr exec -- gnat`)
- **ARM GCC**: `/opt/arm-toolchain/bin/arm-none-eabi-gcc`
- **GPRbuild**: Managed by Alire (use `alr exec -- gprbuild`)

### Alire Configuration

The project includes an `alire.toml` file that specifies:
- GNAT compiler version requirements
- GPRbuild dependency
- Project metadata

## Notes

- The container runs as user `vscode` (UID 1000) for security
- **IMPORTANT**: All GNAT toolchain commands must be run through Alire (`alr exec --`)
- ARM GCC is available directly in PATH for bare-metal cross-compilation
- Alire manages GNAT and GPRbuild to ensure version consistency

## Troubleshooting

### GNAT Toolchain Issues
If you encounter GNAT toolchain errors:
```bash
# Verify Alire toolchain
alr toolchain

# Reinstall toolchain if needed
alr toolchain --select gnat_native gprbuild
```

### GNAT Cross-Compiler
For ARM cross-compilation, the container provides ARM GCC directly. For Ada support on ARM targets, you may need:
- AdaCore's GNAT Community Edition with ARM support (can be managed via Alire)
- Build GNAT from source for ARM targets
- Use GNAT Pro (commercial license required)

### Permissions
If you encounter permission issues, ensure the workspace is mounted with correct permissions.

### Build Errors
Check that all Python dependencies are installed:
```bash
pip3 list | grep -E "(pyyaml|jinja2|pyelftools|intelhex)"
```

## Resources

- [BB-Runtimes Documentation](../README.md)
- [AdaCore Documentation](https://docs.adacore.com/)
- [Alire Package Manager](https://alire.ada.dev/)
- [Alire Documentation](https://alire.ada.dev/docs/)
- [ARM GCC Documentation](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)

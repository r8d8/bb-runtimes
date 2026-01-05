# Migration to Alire Toolchain Management

## Overview

This workspace has been migrated to use **Alire** (Ada package manager) for managing GNAT toolchains instead of manual installation. This ensures better version management, reproducibility, and follows modern Ada development best practices.

## Changes Made

### 1. Created `alire.toml`
- Added project manifest for Alire
- Specified GNAT version requirements (^14.1.0)
- Configured GPRbuild dependency

### 2. Updated Dockerfile (`.devcontainer/Dockerfile`)
- Added Alire installation (v2.0.2)
- Kept minimal bootstrap GNAT for Alire initial setup
- Removed manual GNAT symlink configuration
- Updated PATH to use Alire-managed toolchains

### 3. Updated `post-create.sh`
- Added Alire toolchain initialization
- Configured automatic toolchain selection (gnat_native, gprbuild)
- Updated version checks to use Alire commands

### 4. Updated Documentation (`.devcontainer/README.md`)
- Added Alire usage instructions
- Updated all build commands to use `alr exec --`
- Added troubleshooting section for Alire
- Added links to Alire documentation

## How to Use

### Running Commands

All GNAT toolchain commands must now be executed through Alire:

```bash
# Build a runtime
alr exec -- python build_rts.py --output=build <board>

# Use gprbuild directly
alr exec -- gprbuild -P <project-file>

# Check GNAT version
alr exec -- gnat --version
```

### Toolchain Management

```bash
# View installed toolchains
alr toolchain

# Select specific toolchain
alr toolchain --select gnat_native gprbuild

# Install additional toolchains
alr toolchain --install <toolchain-name>
```

### Why Use Alire?

1. **Version Control**: Ensures consistent GNAT versions across environments
2. **Dependency Management**: Automatically handles dependencies
3. **Reproducibility**: Same toolchain configuration everywhere
4. **Modern Practice**: Alire is the standard Ada package manager
5. **Flexibility**: Easy to switch between toolchain versions

## Rebuilding the Container

To apply these changes:

1. Rebuild the devcontainer:
   - Press `F1` in VS Code
   - Select "Dev Containers: Rebuild Container"
   
2. Wait for the container to build and initialize

3. Verify Alire setup:
   ```bash
   alr version
   alr toolchain
   ```

## Compatibility Notes

- **ARM GCC**: Still installed directly at `/opt/arm-toolchain/bin` (not managed by Alire)
- **Bootstrap GNAT**: A minimal GNAT-13 is installed for Alire's initial operation
- **Python Tools**: No changes to Python package management

## Troubleshooting

### "GNAT not found" errors

Always use `alr exec --` prefix:
```bash
# Wrong
gnat --version

# Correct
alr exec -- gnat --version
```

### Toolchain not initialized

Run in the workspace:
```bash
alr toolchain --select gnat_native gprbuild
```

### Build script errors

Ensure you're in the workspace directory with `alire.toml` present.

## Additional Resources

- [Alire Official Website](https://alire.ada.dev/)
- [Alire Documentation](https://alire.ada.dev/docs/)
- [Alire GitHub](https://github.com/alire-project/alire)

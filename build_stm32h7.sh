#!/bin/bash
# Build script for STM32H7 runtime
# Sets up the complete toolchain environment and builds the runtime

set -e

# Setup ARM toolchain
ARM_TOOLCHAIN="/opt/arm-toolchain/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi"
ALIRE_GPRBUILD="/home/vscode/.local/share/alire/toolchains/gprbuild_25.0.1_9a2e6cfb/bin"
ALIRE_GNAT="/home/vscode/.local/share/alire/toolchains/gnat_native_14.2.1_50f7c8d3/bin"

# Create arm-eabi-* symlinks if they don't exist
LINK_DIR="/tmp/arm-eabi-links"
if [ ! -d "$LINK_DIR" ]; then
    mkdir -p "$LINK_DIR"
    cd "$LINK_DIR"
    for tool in gcc g++ gnatbind gnatls gnatmake gprbuild gprconfig gprls ar as ld objcopy objdump ranlib nm size strip; do
        if [ -f "$ARM_TOOLCHAIN/bin/arm-none-eabi-$tool" ]; then
            ln -sf "$ARM_TOOLCHAIN/bin/arm-none-eabi-$tool" "arm-eabi-$tool"
        fi
    done
fi

# Setup PATH with all required tools
export PATH="$LINK_DIR:$ARM_TOOLCHAIN/bin:$ALIRE_GPRBUILD:$ALIRE_GNAT:$PATH"

# Verify tools are available
echo "=== Toolchain Verification ==="
echo -n "ARM GCC: "
arm-eabi-gcc --version | head -1
echo -n "GPRbuild: "
gprbuild --version | head -1
echo -n "GPRls: "
gprls --version | head -1
echo ""

# Show usage
if [ $# -eq 0 ]; then
    echo "Usage: $0 [board] [output_dir]"
    echo ""
    echo "Examples:"
    echo "  $0 stm32h743disco /tmp/runtime"
    echo "  $0 stm32h743 build"
    echo ""
    echo "Available STM32H7 boards:"
    echo "  - stm32h743disco (STM32H743 Discovery)"
    echo "  - stm32h743 (Generic STM32H743)"
    echo "  - stm32h750disco (STM32H750 Discovery)"
    exit 1
fi

BOARD="${1:-stm32h743disco}"
OUTPUT="${2:-/tmp/stm32h7_runtime}"

echo "=== Building STM32H7 Runtime ==="
echo "Board: $BOARD"
echo "Output: $OUTPUT"
echo ""

# Note: This will fail without rts-sources.json from GNAT sources
# For now, just test that the BSP configuration is correct
echo "Testing BSP configuration..."
python3 -c "from arm.cortexm import Stm32; t = Stm32('$BOARD'); print('✓ Board:', t.board); print('✓ MCU:', t.mcu); print('✓ Cortex:', t.cortex)"

echo ""
echo "Note: Full runtime build requires rts-sources.json from GNAT sources."
echo "BSP files are located in: arm/stm32/stm32h7x/"
echo ""
echo "To complete the build, you need:"
echo "1. GNAT Pro or Community sources"
echo "2. Run gen_rts_sources.py to generate rts-sources.json"
echo "3. Then run: python3 build_rts.py --output=$OUTPUT --build $BOARD"

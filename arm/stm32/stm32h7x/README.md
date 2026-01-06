# STM32H7 Runtime Support

This directory contains the Ada bare-metal runtime support for STM32H7 microcontrollers.

## Supported Boards

- **stm32h743disco** - STM32H743 Discovery Kit
- **stm32h743** - Generic STM32H743 devices
- **stm32h750disco** - STM32H750 Discovery Kit

## Files

### Core Runtime Files
- `memory-map.ld` - Memory layout for STM32H7 devices
  - 2MB Flash, 128KB DTCM, 64KB ITCM
  - 512KB AXI SRAM (main RAM)
  - Additional SRAM1/2/3/4 regions

- `s-bbmcpa.ads/adb` - MCU Parameters
  - 150 interrupt vectors
  - Power initialization (LDO regulator, voltage scaling)

- `s-stm32.adb` - System Clock Implementation
  - PLL configuration
  - D1/D2/D3 domain clock management
  - APB1/2/3/4 prescalers

### SVD Generated Files (svd/)
Generated from STM32H743.svd using svd2ada:

- `i-stm32.ads` - Base types and peripheral addresses
- `i-stm32-rcc.ads` - Reset and Clock Control (4626 lines)
- `i-stm32-pwr.ads` - Power Management (636 lines)
- `i-stm32-flash.ads` - Flash Memory Controller (1485 lines)
- `i-stm32-gpio.ads` - GPIO Configuration (524 lines)
- `i-stm32-syscfg.ads` - System Configuration (848 lines)
- `i-stm32-usart.ads` - UART/USART (844 lines)
- `handler.S` - Interrupt vector table (214 lines, 150 interrupts)
- `a-intnam.ads` - Interrupt names (440 lines)

## Configuration

Clock configuration (default):
- Main Clock: 400 MHz
- HSE Clock: 25 MHz  
- Flash Latency: 4

## Building

**IMPORTANT:** This repository requires GCC and GNAT **source code** (not just binaries) to generate complete runtimes. The BSP implementation is complete, but the full Ada runtime library sources are needed.

### Prerequisites
- ARM cross-compiler (arm-eabi-gcc)
- GPRbuild and GNAT
- GCC source repository (for runtime library sources)
- GNAT source repository (for runtime library sources)

### Build Steps

```bash
# 1. Generate runtime source descriptor (requires GCC/GNAT sources)
python3 gen_rts_sources.py \
  --gcc-dir=/path/to/gcc-sources \
  --gnat-dir=/path/to/gnat-sources \
  --output-descriptor=obj/rts.json \
  --output-sources=obj/rts-sources \
  --rts-profile=embedded

# 2. Generate and build runtime
make TARGET=arm-eabi stm32h743disco.build

# OR using build_rts.py directly:
python3 build_rts.py --rts-src-descriptor=obj/rts.json \
  --output=obj --build stm32h743disco
```

### BSP Status
✅ All BSP files complete and validated
✅ Memory layout configured for STM32H743/H750
✅ SVD peripheral interfaces generated (9 files, ~387KB)
✅ Board configurations integrated into build system
⏸️ Full runtime build requires GCC/GNAT source repositories

## Regenerating SVD Files

To regenerate the interface files from the SVD description:

```bash
# Download STM32H743.svd from:
# https://github.com/modm-io/cmsis-svd-stm32/blob/main/stm32h7/STM32H743.svd

# Generate Ada bindings
svd2ada STM32H743.svd -o stm32h7x/svdtmp -p Interfaces.STM32

# Move required files to svd/
cd stm32h7x/svdtmp
mv i-stm32*.ads handler.S a-intnam.ads ../svd/

# Fix CPU type in handler.S
sed -i 's/cortex-m4/cortex-m7/g' ../svd/handler.S
```

## Notes

- The STM32H7 has a more complex clock tree than F4/F7 with separate D1/D2/D3 domains
- Power management uses LDO regulator with voltage scaling instead of overdrive mode
- Memory includes tightly-coupled memory (DTCM/ITCM) for critical code/data

## Created

January 5, 2026 - Initial STM32H7 runtime implementation

------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--          Copyright (C) 2012-2026, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  STM32H7 PLL and clock initialization
--
--  This sets up the system to run at 400 MHz from the PLL
--  Using HSE (25 MHz) as source
--  Power: VOS Scale 1 (highest performance)
--  Flash: 4 wait states for 400 MHz at VOS1

pragma Ada_2012;
pragma Suppress (All_Checks);

with Ada.Unchecked_Conversion;

with Interfaces.STM32;           use Interfaces, Interfaces.STM32;
with Interfaces.STM32.Flash;     use Interfaces.STM32.Flash;
with Interfaces.STM32.RCC;       use Interfaces.STM32.RCC;
with Interfaces.STM32.PWR;       use Interfaces.STM32.PWR;

with System.BB.Parameters;       use System.BB.Parameters;
with System.BB.MCU_Parameters;
with System.BB.Board_Parameters; use System.BB.Board_Parameters;
with System.STM32;               use System.STM32;

procedure Setup_Pll is

   procedure Initialize_Clocks;
   procedure Reset_Clocks;

   ------------------------------
   -- Clock Tree Configuration --
   ------------------------------

   HSE_Enabled : constant Boolean := True;  -- use high-speed external clock
   HSE_Bypass  : constant Boolean := False; -- bypass osc with external clock

   HSI_Enabled : constant Boolean := False; -- use high-speed internal clock
   CSI_Enabled : constant Boolean :=
     (if not HSE_Enabled and not HSI_Enabled then True);
   --  Use low-power internal clock when HSE and HSI are disabled

   Activate_PLL : constant Boolean := True;
   Activate_Overdrive : constant Boolean := False; -- VOS0 for 480 MHz

   --  STM32H7 internal clock frequencies
   HSI_Clock : constant := 64_000_000;  -- 64 MHz
   CSI_Clock : constant :=  4_000_000;  -- 4 MHz

   --  Power management: VOS1 for 400 MHz (11b = 3)
   Scale_1 : constant := 3;

   --  APB prescalers for 100 MHz from 200 MHz
   APB1_PRE : constant APB_Prescaler := (Enabled => True, Value => DIV2);
   APB2_PRE : constant APB_Prescaler := (Enabled => True, Value => DIV2);
   APB3_PRE : constant APB_Prescaler := (Enabled => True, Value => DIV2);
   APB4_PRE : constant APB_Prescaler := (Enabled => True, Value => DIV2);

   --  AHB prescalers: divide SYSCLK by 2 for 200 MHz HCLK
   AHB_PRE : constant AHB_Prescaler := (Enabled => True, Value => DIV2);

   SW : constant SYSCLK_Source :=
     (if Activate_PLL then SYSCLK_SRC_PLL
      elsif HSE_Enabled then SYSCLK_SRC_HSE
      elsif HSI_Enabled then SYSCLK_SRC_HSI
      else SYSCLK_SRC_CSI);

   -------------------------------
   -- Compute Clock Frequencies --
   -------------------------------

   PLLCLKIN : constant Integer := 4_000_000;
   --  Target PLL input frequency (4 MHz for compatibility with CSI)

   PLL1M_Value : constant Integer :=
     (if HSE_Enabled then HSE_Clock
      elsif HSI_Enabled then HSI_Clock
      else CSI_Clock) / PLLCLKIN;
   --  First divider DIVM1 to produce PLLCLKIN

   PLL1P_Value : constant := 2;  -- DIVP1 for system clock
   
   PLL1N_Value : constant Integer :=
     (PLL1P_Value * Clock_Frequency) / PLLCLKIN;
   --  Compute DIVN1 to generate required frequency

   pragma Compile_Time_Error
     (Activate_PLL and PLL1M_Value not in PLLM_Range,
      "Invalid PLL1M clock configuration value");

   pragma Compile_Time_Error
     (Activate_PLL and PLL1N_Value not in PLLN_Range,
      "Invalid PLL1N clock configuration value");

   pragma Compile_Time_Error
     (Activate_PLL and
      (PLL1P_Value rem 2 /= 0 or PLL1P_Value not in PLL1P_Range),
      "Invalid PLL1P clock configuration value");

   PLLVCO : constant Integer := PLLCLKIN * PLL1N_Value;

   pragma Compile_Time_Error
     (Activate_PLL and PLLVCO not in PLLN_OUT_Range,
      "Invalid PLL VCO output frequency");

   PLLCLKOUT : constant Integer := PLLVCO / PLL1P_Value;

   pragma Compile_Time_Error
     (Activate_PLL and PLLCLKOUT not in PLLCLK_Range,
      "Invalid PLL output frequency");

   PLL1M : constant UInt6 := UInt6 (PLL1M_Value);
   PLL1N : constant UInt9 := UInt9 (PLL1N_Value - 1);
   PLL1P : constant UInt7 := UInt7 (PLL1P_Value - 1);

   SYSCLK : constant Integer :=
     (if Activate_PLL then PLLCLKOUT
      elsif HSE_Enabled then HSE_Clock
      elsif HSI_Enabled then HSI_Clock
      else CSI_Clock);

   pragma Compile_Time_Error
     (SYSCLK /= Clock_Frequency,
      "Cannot generate requested clock frequency");

   function To_AHB is new Ada.Unchecked_Conversion (AHB_Prescaler, UInt4);
   function To_APB is new Ada.Unchecked_Conversion (APB_Prescaler, UInt3);

   -----------------------
   -- Initialize_Clocks --
   -----------------------

   procedure Initialize_Clocks is
   begin
      --  PWR initialization
      System.BB.MCU_Parameters.PWR_Initialize;

      if HSE_Enabled then
         --  Configure high-speed external clock
         RCC_Periph.CR.HSEBYP := (if HSE_Bypass then 1 else 0);
         --  Enable security for HSE
         RCC_Periph.CR.HSECSSON := 1;
         --  Enable HSE oscillator
         RCC_Periph.CR.HSEON := 1;
         --  Wait for HSE stabilization
         loop
            exit when RCC_Periph.CR.HSERDY = 1;
         end loop;

      else
         if HSI_Enabled then
            --  Enable high-speed internal clock
            RCC_Periph.CR.HSION := 1;
            loop
               exit when RCC_Periph.CR.HSIRDY = 1;
            end loop;
         elsif CSI_Enabled then
            --  Enable low-power internal clock
            RCC_Periph.CR.CSION := 1;
            loop
               exit when RCC_Periph.CR.CSIRDY = 1;
            end loop;
         end if;
      end if;

      --  Activate PLL if enabled
      if Activate_PLL then
         --  Disable PLL1 before configuration
         RCC_Periph.CR.PLL1ON := 0;

         --  Configure PLL source and dividers
         RCC_Periph.PLLCKSELR :=
           (PLLSRC => (if HSE_Enabled then PLL_SRC_HSE'Enum_Rep
                       elsif HSI_Enabled then PLL_SRC_HSI'Enum_Rep
                       else PLL_SRC_CSI'Enum_Rep),
            DIVM1  => PLL1M,
            others => <>);

         RCC_Periph.PLLCFGR :=
           (PLL1VCOSEL  => 0, -- Wide VCO range: 192-960 MHz
            PLL1RGE     => 2, -- Input range: 4-8 MHz
            PLL1FRACEN  => 0, -- Disable fractional mode
            DIVP1EN     => 1, -- Enable DIVP output
            others      => <>);

         RCC_Periph.PLL1DIVR :=
           (DIVN1  => PLL1N,
            DIVP1  => PLL1P,
            others => <>);

         --  Enable PLL and wait for lock
         RCC_Periph.CR.PLL1ON := 1;
         loop
            exit when RCC_Periph.CR.PLL1RDY = 1;
         end loop;

         --  Set VCORE to VOS1 after PLL is ready
         PWR_Periph.D3CR.VOS := Scale_1;
      end if;

      --  Configure Flash wait states before frequency increase
      --  Flash latency for AXI interface clock (HCLK)
      FLASH_Periph.ACR.LATENCY := FLASH_Latency;

      --  Configure domain clocks
      RCC_Periph.D1CFGR :=
        (HPRE   => To_AHB (AHB_PRE),   -- AHB prescaler
         D1CPRE => To_AHB (AHB_PRE),   -- CPU prescaler  
         D1PPRE => To_APB (APB3_PRE),  -- APB3 prescaler
         others => <>);

      RCC_Periph.D2CFGR :=
        (D2PPRE1 => To_APB (APB1_PRE), -- APB1 prescaler
         D2PPRE2 => To_APB (APB2_PRE), -- APB2 prescaler
         others  => <>);

      RCC_Periph.D3CFGR :=
        (D3PPRE => To_APB (APB4_PRE),  -- APB4 prescaler
         others => <>);

      --  Switch system clock source
      RCC_Periph.CFGR.SW := SW'Enum_Rep;

      --  Wait for system clock switch
      case SW is
         when SYSCLK_SRC_PLL =>
            loop
               exit when RCC_Periph.CFGR.SWS = SYSCLK_SRC_PLL'Enum_Rep;
            end loop;
         when SYSCLK_SRC_HSE =>
            loop
               exit when RCC_Periph.CFGR.SWS = SYSCLK_SRC_HSE'Enum_Rep;
            end loop;
         when SYSCLK_SRC_HSI =>
            loop
               exit when RCC_Periph.CFGR.SWS = SYSCLK_SRC_HSI'Enum_Rep;
            end loop;
         when SYSCLK_SRC_CSI =>
            loop
               exit when RCC_Periph.CFGR.SWS = SYSCLK_SRC_CSI'Enum_Rep;
            end loop;
      end case;

      --  Activate overdrive for 480 MHz if requested
      if Activate_Overdrive then
         System.BB.MCU_Parameters.PWR_Overdrive_Enable;
      end if;

   end Initialize_Clocks;

   ------------------
   -- Reset_Clocks --
   ------------------

   procedure Reset_Clocks is
   begin
      --  Switch to high-speed internal clock
      RCC_Periph.CR.HSION := 1;

      --  Reset CFGR register
      RCC_Periph.CFGR := (others => <>);

      --  Reset clock control bits
      RCC_Periph.CR.HSEON := 0;
      RCC_Periph.CR.HSECSSON := 0;
      RCC_Periph.CR.PLL1ON := 0;

      --  Reset PLL configuration
      RCC_Periph.PLLCFGR := (others => <>);

      --  Reset HSE bypass
      RCC_Periph.CR.HSEBYP := 0;

      --  Disable all interrupts
      RCC_Periph.CIER := (others => <>);
   end Reset_Clocks;

begin
   Reset_Clocks;
   Initialize_Clocks;
end Setup_Pll;

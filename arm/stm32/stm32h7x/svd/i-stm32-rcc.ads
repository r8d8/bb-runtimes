--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x RCC
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.RCC is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   ---------------
   -- Registers --
   ---------------

   --  Simplified RCC register definitions for STM32H7

   subtype CR_HSION_Field is Interfaces.STM32.Bit;
   subtype CR_HSIRDY_Field is Interfaces.STM32.Bit;
   subtype CR_HSEON_Field is Interfaces.STM32.Bit;
   subtype CR_HSERDY_Field is Interfaces.STM32.Bit;

   --  Clock control register
   type CR_Register is record
      HSION          : CR_HSION_Field := 16#1#;
      HSIRDY         : CR_HSIRDY_Field := 16#0#;
      Reserved_2_15  : Interfaces.STM32.UInt14 := 16#0#;
      HSEON          : CR_HSEON_Field := 16#0#;
      HSERDY         : CR_HSERDY_Field := 16#0#;
      Reserved_18_31 : Interfaces.STM32.UInt14 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CR_Register use record
      HSION          at 0 range 0 .. 0;
      HSIRDY         at 0 range 1 .. 1;
      Reserved_2_15  at 0 range 2 .. 15;
      HSEON          at 0 range 16 .. 16;
      HSERDY         at 0 range 17 .. 17;
      Reserved_18_31 at 0 range 18 .. 31;
   end record;

   --  Clock configuration register
   type CFGR_Register is record
      SWS : UInt2 := 16#0#;
      Reserved : UInt30 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CFGR_Register use record
      SWS      at 0 range 3 .. 4;
      Reserved at 0 range 5 .. 31;
   end record;

   --  PLL clock source selection register
   type PLLCKSELR_Register is record
      PLLSRC : UInt2 := 16#0#;
      Reserved_2_3 : UInt2 := 16#0#;
      DIVM1 : UInt6 := 16#0#;
      Reserved : UInt22 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for PLLCKSELR_Register use record
      PLLSRC       at 0 range 0 .. 1;
      Reserved_2_3 at 0 range 2 .. 3;
      DIVM1        at 0 range 4 .. 9;
      Reserved     at 0 range 10 .. 31;
   end record;

   --  PLL1 dividers register
   type PLL1DIVR_Register is record
      DIVN1 : UInt9 := 16#0#;
      Reserved_9_15 : UInt7 := 16#0#;
      DIVP1 : UInt7 := 16#0#;
      Reserved : UInt9 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for PLL1DIVR_Register use record
      DIVN1         at 0 range 0 .. 8;
      Reserved_9_15 at 0 range 9 .. 15;
      DIVP1         at 0 range 16 .. 22;
      Reserved      at 0 range 23 .. 31;
   end record;

   --  Domain 1 clock configuration register
   type D1CFGR_Register is record
      Reserved_0_3 : UInt4 := 16#0#;
      D1CPRE : UInt4 := 16#0#;
      D1PPRE : UInt3 := 16#0#;
      Reserved_11_11 : Bit := 16#0#;
      HPRE : UInt4 := 16#0#;
      Reserved : UInt16 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for D1CFGR_Register use record
      Reserved_0_3   at 0 range 0 .. 3;
      D1CPRE         at 0 range 4 .. 7;
      D1PPRE         at 0 range 8 .. 10;
      Reserved_11_11 at 0 range 11 .. 11;
      HPRE           at 0 range 12 .. 15;
      Reserved       at 0 range 16 .. 31;
   end record;

   --  Domain 2 clock configuration register
   type D2CFGR_Register is record
      Reserved_0_7 : UInt8 := 16#0#;
      D2PPRE1 : UInt3 := 16#0#;
      Reserved_11_11 : Bit := 16#0#;
      D2PPRE2 : UInt3 := 16#0#;
      Reserved : UInt17 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for D2CFGR_Register use record
      Reserved_0_7   at 0 range 0 .. 7;
      D2PPRE1        at 0 range 8 .. 10;
      Reserved_11_11 at 0 range 11 .. 11;
      D2PPRE2        at 0 range 12 .. 14;
      Reserved       at 0 range 15 .. 31;
   end record;

   --  Domain 3 clock configuration register
   type D3CFGR_Register is record
      Reserved_0_7 : UInt8 := 16#0#;
      D3PPRE : UInt3 := 16#0#;
      Reserved : UInt21 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for D3CFGR_Register use record
      Reserved_0_7 at 0 range 0 .. 7;
      D3PPRE       at 0 range 8 .. 10;
      Reserved     at 0 range 11 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   type RCC_Peripheral is record
      CR         : CR_Register;
      CFGR       : CFGR_Register;
      PLLCKSELR  : PLLCKSELR_Register;
      PLL1DIVR   : PLL1DIVR_Register;
      D1CFGR     : D1CFGR_Register;
      D2CFGR     : D2CFGR_Register;
      D3CFGR     : D3CFGR_Register;
   end record
     with Volatile;

   for RCC_Peripheral use record
      CR        at 16#00# range 0 .. 31;
      CFGR      at 16#10# range 0 .. 31;
      PLLCKSELR at 16#28# range 0 .. 31;
      PLL1DIVR  at 16#30# range 0 .. 31;
      D1CFGR    at 16#18# range 0 .. 31;
      D2CFGR    at 16#1C# range 0 .. 31;
      D3CFGR    at 16#18# range 0 .. 31;
   end record;

   RCC_Periph : aliased RCC_Peripheral
     with Import, Address => RCC_Base;

   type SYSCLK_Source is
     (SYSCLK_SRC_HSI,
      SYSCLK_SRC_CSI,
      SYSCLK_SRC_HSE,
      SYSCLK_SRC_PLL);

   type PLL_Source is
     (PLL_SRC_HSI,
      PLL_SRC_CSI,
      PLL_SRC_HSE,
      PLL_SRC_NONE);

end Interfaces.STM32.RCC;

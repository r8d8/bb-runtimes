--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x SYSCFG
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.SYSCFG is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   type SYSCFG_Peripheral is record
      MEMRMP : UInt32;
      PMC    : UInt32;
   end record
     with Volatile;

   for SYSCFG_Peripheral use record
      MEMRMP at 16#00# range 0 .. 31;
      PMC    at 16#04# range 0 .. 31;
   end record;

   SYSCFG_Periph : aliased SYSCFG_Peripheral
     with Import, Address => SYSCFG_Base;

end Interfaces.STM32.SYSCFG;

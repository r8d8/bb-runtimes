--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x FLASH
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.FLASH is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   type FLASH_Peripheral is record
      ACR : UInt32;
   end record
     with Volatile;

   for FLASH_Peripheral use record
      ACR at 16#00# range 0 .. 31;
   end record;

   FLASH_Periph : aliased FLASH_Peripheral
     with Import, Address => FLASH_Base;

end Interfaces.STM32.FLASH;

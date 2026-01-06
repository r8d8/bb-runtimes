--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x GPIO
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.GPIO is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   type GPIO_Peripheral is record
      MODER   : UInt32;
      OTYPER  : UInt32;
      OSPEEDR : UInt32;
      PUPDR   : UInt32;
      IDR     : UInt32;
      ODR     : UInt32;
      BSRR    : UInt32;
      LCKR    : UInt32;
      AFRL    : UInt32;
      AFRH    : UInt32;
   end record
     with Volatile;

   for GPIO_Peripheral use record
      MODER   at 16#00# range 0 .. 31;
      OTYPER  at 16#04# range 0 .. 31;
      OSPEEDR at 16#08# range 0 .. 31;
      PUPDR   at 16#0C# range 0 .. 31;
      IDR     at 16#10# range 0 .. 31;
      ODR     at 16#14# range 0 .. 31;
      BSRR    at 16#18# range 0 .. 31;
      LCKR    at 16#1C# range 0 .. 31;
      AFRL    at 16#20# range 0 .. 31;
      AFRH    at 16#24# range 0 .. 31;
   end record;

end Interfaces.STM32.GPIO;

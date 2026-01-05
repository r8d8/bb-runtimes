--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x USART
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.USART is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   type USART_Peripheral is record
      CR1    : UInt32;
      CR2    : UInt32;
      CR3    : UInt32;
      BRR    : UInt32;
      GTPR   : UInt32;
      RTOR   : UInt32;
      RQR    : UInt32;
      ISR    : UInt32;
      ICR    : UInt32;
      RDR    : UInt32;
      TDR    : UInt32;
   end record
     with Volatile;

   for USART_Peripheral use record
      CR1  at 16#00# range 0 .. 31;
      CR2  at 16#04# range 0 .. 31;
      CR3  at 16#08# range 0 .. 31;
      BRR  at 16#0C# range 0 .. 31;
      GTPR at 16#10# range 0 .. 31;
      RTOR at 16#14# range 0 .. 31;
      RQR  at 16#18# range 0 .. 31;
      ISR  at 16#1C# range 0 .. 31;
      ICR  at 16#20# range 0 .. 31;
      RDR  at 16#24# range 0 .. 31;
      TDR  at 16#28# range 0 .. 31;
   end record;

end Interfaces.STM32.USART;

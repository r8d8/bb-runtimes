--
--  Copyright (C) 2026, AdaCore
--

--  This spec is a placeholder for STM32H7x PWR
--  Complete SVD files should be generated using svd2ada tool

pragma Ada_2012;
pragma Style_Checks (Off);

with System;

package Interfaces.STM32.PWR is
   pragma Preelaborate;
   pragma No_Elaboration_Code_All;

   ---------------
   -- Registers --
   ---------------

   --  Power control register 1
   type CR1_Register is record
      LPDS : Bit := 16#0#;
      PVDE : Bit := 16#0#;
      PLS : UInt3 := 16#0#;
      DBP : Bit := 16#0#;
      FLPS : Bit := 16#0#;
      Reserved_7_13 : UInt7 := 16#0#;
      SVOS : UInt2 := 16#0#;
      AVDEN : Bit := 16#0#;
      ALS : UInt2 := 16#0#;
      Reserved : UInt13 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CR1_Register use record
      LPDS          at 0 range 0 .. 0;
      PVDE          at 0 range 1 .. 1;
      PLS           at 0 range 2 .. 4;
      DBP           at 0 range 5 .. 5;
      FLPS          at 0 range 6 .. 6;
      Reserved_7_13 at 0 range 7 .. 13;
      SVOS          at 0 range 14 .. 15;
      AVDEN         at 0 range 16 .. 16;
      ALS           at 0 range 17 .. 18;
      Reserved      at 0 range 19 .. 31;
   end record;

   --  Power control register 3
   type CR3_Register is record
      BYPASS : Bit := 16#0#;
      LDOEN : Bit := 16#0#;
      SCUEN : Bit := 16#0#;
      Reserved_3_1 : Bit := 16#0#;
      VBE : Bit := 16#0#;
      VBRS : Bit := 16#0#;
      Reserved : UInt26 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CR3_Register use record
      BYPASS       at 0 range 0 .. 0;
      LDOEN        at 0 range 1 .. 1;
      SCUEN        at 0 range 2 .. 2;
      Reserved_3_1 at 0 range 3 .. 3;
      VBE          at 0 range 4 .. 4;
      VBRS         at 0 range 5 .. 5;
      Reserved     at 0 range 6 .. 31;
   end record;

   --  Power domain 3 control register
   type D3CR_Register is record
      Reserved_0_13 : UInt14 := 16#0#;
      VOS : UInt2 := 16#0#;
      VOSRDY : Bit := 16#0#;
      Reserved : UInt15 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for D3CR_Register use record
      Reserved_0_13 at 0 range 0 .. 13;
      VOS           at 0 range 14 .. 15;
      VOSRDY        at 0 range 16 .. 16;
      Reserved      at 0 range 17 .. 31;
   end record;

   --  Power control/status register 1
   type CSR1_Register is record
      Reserved_0_3 : UInt4 := 16#0#;
      PVDO : Bit := 16#0#;
      Reserved_5_12 : UInt8 := 16#0#;
      ACTVOSRDY : Bit := 16#0#;
      ACTVOS : UInt2 := 16#0#;
      AVDO : Bit := 16#0#;
      Reserved : UInt16 := 16#0#;
   end record
     with Volatile_Full_Access, Size => 32,
          Bit_Order => System.Low_Order_First;

   for CSR1_Register use record
      Reserved_0_3  at 0 range 0 .. 3;
      PVDO          at 0 range 4 .. 4;
      Reserved_5_12 at 0 range 5 .. 12;
      ACTVOSRDY     at 0 range 13 .. 13;
      ACTVOS        at 0 range 14 .. 15;
      AVDO          at 0 range 16 .. 16;
      Reserved      at 0 range 17 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   type PWR_Peripheral is record
      CR1  : CR1_Register;
      CSR1 : CSR1_Register;
      CR3  : CR3_Register;
      D3CR : D3CR_Register;
   end record
     with Volatile;

   for PWR_Peripheral use record
      CR1  at 16#00# range 0 .. 31;
      CSR1 at 16#04# range 0 .. 31;
      CR3  at 16#0C# range 0 .. 31;
      D3CR at 16#18# range 0 .. 31;
   end record;

   PWR_Periph : aliased PWR_Peripheral
     with Import, Address => PWR_Base;

end Interfaces.STM32.PWR;

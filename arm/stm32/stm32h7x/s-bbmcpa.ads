------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--              S Y S T E M . B B . M C U _ P A R A M E T E R S             --
--                                                                          --
--                                  S p e c                                 --
--                                                                          --
--                      Copyright (C) 2016-2026, AdaCore                    --
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
-- The port of GNARL to bare board targets was initially developed by the   --
-- Real-Time Systems Group at the Technical University of Madrid.           --
--                                                                          --
------------------------------------------------------------------------------

--  This package defines MCU parameters for the STM32H7x family

with Interfaces.STM32;
with Interfaces.STM32.PWR;

package System.BB.MCU_Parameters is
   pragma No_Elaboration_Code_All;
   pragma Preelaborate;
   use type Interfaces.STM32.Bit;

   --  STM32H7x3 has 150 interrupts (0-149)
   Number_Of_Interrupts : constant := 150;

   procedure PWR_Initialize;

   procedure PWR_Overdrive_Enable;

private

   PWR_CR3_LDOEN : constant := 16#0002#;  --  Low Drop-out Regulator Enable
   PWR_CR3_BYPASS : constant := 16#0001#; --  Power Management Unit bypass
   
   PWR_D3CR_VOS_Scale_3 : constant := 16#0000#;  --  VOS Scale 3
   PWR_D3CR_VOS_Scale_2 : constant := 16#0001#;  --  VOS Scale 2
   PWR_D3CR_VOS_Scale_1 : constant := 16#0002#;  --  VOS Scale 1
   PWR_D3CR_VOS_Scale_0 : constant := 16#0003#;  --  VOS Scale 0

end System.BB.MCU_Parameters;

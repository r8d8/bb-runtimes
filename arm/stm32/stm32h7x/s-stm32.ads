------------------------------------------------------------------------------
--                                                                          --
--                  GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                --
--                                                                          --
--                          S Y S T E M . S T M 32                          --
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

--  This file provides declarations for peripherals for the STM32H7 family

with Interfaces;
with System.BB.Parameters;
with System.BB.MCU_Parameters;

package System.STM32 is
   pragma No_Elaboration_Code_All;
   pragma Preelaborate (STM32);

   subtype Frequency is Interfaces.Unsigned_32;

   type RCC_System_Clocks is record
      SYSCLK  : Frequency;
      HCLK    : Frequency;
      PCLK1   : Frequency;
      PCLK2   : Frequency;
      TIMCLK1 : Frequency;
      TIMCLK2 : Frequency;
   end record;

   function System_Clocks return RCC_System_Clocks;

   --  STM32H7 can run up to 480 MHz (STM32H750) or 550 MHz (STM32H7A3/B3)
   --  but typical maximum is 400 MHz for STM32H743
   subtype SYSCLK_Range is Integer range 1 .. 550_000_000;

end System.STM32;

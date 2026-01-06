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

with System.BB.Parameters;

with Interfaces;            use Interfaces;
with Interfaces.STM32;      use Interfaces.STM32;
with Interfaces.STM32.RCC;  use Interfaces.STM32.RCC;

package body System.STM32 is

   package Param renames System.BB.Parameters;

   --  STM32H7 has different prescaler encoding
   D1CPRE_Presc_Table : constant array (0 .. 15) of UInt32 :=
     (1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 8, 16, 64, 128, 256, 512);

   HPRE_Presc_Table : constant array (0 .. 15) of UInt32 :=
     (1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 8, 16, 64, 128, 256, 512);

   PPRE_Presc_Table : constant array (0 .. 7) of UInt32 :=
     (1, 1, 1, 1, 2, 4, 8, 16);

   -------------------
   -- System_Clocks --
   -------------------

   function System_Clocks return RCC_System_Clocks
   is
      Source       : constant UInt32 := UInt32 (RCC_Periph.CFGR.SWS);
      Result       : RCC_System_Clocks;

   begin
      --  System clock source: 000=HSI, 001=CSI, 010=HSE, 011=PLL1
      case Source is

         --  HSI as source (64 MHz)

         when 0 =>  --  HSI
            Result.SYSCLK := Param.HSI_Clock;

         --  CSI as source (4 MHz)

         when 1 =>  --  CSI
            Result.SYSCLK := 4_000_000;

         --  HSE as source

         when 2 =>  --  HSE
            Result.SYSCLK := Param.HSE_Clock;

         --  PLL1 as source

         when 3 =>  --  PLL1
            declare
               Pllm   : constant UInt32 :=
                  UInt32 (RCC_Periph.PLLCKSELR.DIVM1);
               Plln   : constant UInt32 :=
                  UInt32 (RCC_Periph.PLL1DIVR.DIVN1) + 1;
               Pllp   : constant UInt32 :=
                  UInt32 (RCC_Periph.PLL1DIVR.DIVP1) + 1;
               Pllvco : UInt32;
               Pllinput : UInt32;

            begin
               --  Get PLL input frequency
               --  PLLSRC: 00=HSI, 01=CSI, 10=HSE, 11=No clock
               case UInt32 (RCC_Periph.PLLCKSELR.PLLSRC) is
                  when 0 =>  --  HSI
                     Pllinput := Param.HSI_Clock / Pllm;
                  when 1 =>  --  CSI
                     Pllinput := 4_000_000 / Pllm;
                  when 2 =>  --  HSE
                     Pllinput := Param.HSE_Clock / Pllm;
                  when others =>  --  No clock
                     Pllinput := 0;
               end case;

               --  Calculate VCO frequency
               Pllvco := Pllinput * Plln;

               --  Calculate system clock
               Result.SYSCLK := Pllvco / Pllp;
            end;

         when others =>
            --  Unknown source, default to HSI
            Result.SYSCLK := Param.HSI_Clock;
      end case;

      declare
         --  D1CPRE: D1 domain Core prescaler (CPU clock)
         D1CPRE_Value : constant Integer :=
            Integer (RCC_Periph.D1CFGR.D1CPRE);
         D1CPRE_Div : constant UInt32 := D1CPRE_Presc_Table (D1CPRE_Value);

         --  HPRE: AHB prescaler (D2 domain)
         HPRE_Value : constant Integer := Integer (RCC_Periph.D1CFGR.HPRE);
         HPRE_Div : constant UInt32 := HPRE_Presc_Table (HPRE_Value);

         --  D2PPRE1: APB1 clock prescaler (D2 domain)
         D2PPRE1_Value : constant Integer :=
            Integer (RCC_Periph.D2CFGR.D2PPRE1);
         D2PPRE1_Div : constant UInt32 := PPRE_Presc_Table (D2PPRE1_Value);

         --  D2PPRE2: APB2 clock prescaler (D2 domain)
         D2PPRE2_Value : constant Integer :=
            Integer (RCC_Periph.D2CFGR.D2PPRE2);
         D2PPRE2_Div : constant UInt32 := PPRE_Presc_Table (D2PPRE2_Value);

      begin
         --  CPU clock (D1 domain)
         Result.SYSCLK := Result.SYSCLK / D1CPRE_Div;

         --  AHB clock (bus matrix, DMA, etc.)
         Result.HCLK := Result.SYSCLK / HPRE_Div;

         --  APB clocks
         Result.PCLK1 := Result.HCLK / D2PPRE1_Div;  -- APB1 (D2 domain)
         Result.PCLK2 := Result.HCLK / D2PPRE2_Div;  -- APB2 (D2 domain)

         --  Timer clocks
         --  If APB prescaler is 1, timer clock = PCLKx
         --  Otherwise, timer clock = 2 * PCLKx
         if D2PPRE1_Div = 1 then
            Result.TIMCLK1 := Result.PCLK1;
         else
            Result.TIMCLK1 := Result.PCLK1 * 2;
         end if;

         if D2PPRE2_Div = 1 then
            Result.TIMCLK2 := Result.PCLK2;
         else
            Result.TIMCLK2 := Result.PCLK2 * 2;
         end if;
      end;

      return Result;
   end System_Clocks;

end System.STM32;

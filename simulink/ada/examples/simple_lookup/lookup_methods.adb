--------------------------------------------------------------------------------
--                                                                            --
-- File    : lookup_methods.adb                             $Revision: 1.5 $  --
-- Abstract:                                                                  --
--      Simple lookup algorithms used in the S-Function ada_direct_lookup     --
--      See the description in simple_lookup.adb for more deltails.           --
--                                                                            --
-- Author  : Murali Yeddanapudi, 15-Aug-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

package body Lookup_Methods is

   -- Procedure: Left_Continuous_Lookup ----------------------------------------
   -- Abstract::
   --      This procedure implements the following simple left continuous
   --      table lookup algorithm:
   --
   --                     InpSig <= XValues(1)  => OutSig = YValues(0)
   --                                              OutIdx = 0
   --      XValues(1)   < InpSig <= XValues(2)  => OutSig = YValues(1)
   --                                              OutIdx = 1
   --      XValues(2)   < InpSig <= XValues(3)  => OutSig = YValues(2)
   --                                              OutIdx = 2
   --                             :
   --                             :
   --      XValues(n-1) < InpSig <= XValues(n)  => OutSig = YValues(n-1)
   --                                              OutIdx = n-1
   --      XValues(n)   < InpSig                   OutSig = YValues(n)
   --                                              OutIdx = n
   --
   procedure Left_Continuous_Lookup(InpSig  : in     Dbl_Array;
                                    OutSig  : out    Dbl_Array;
                                    OutIdx  : in out Int_Array;
                                    XValues : in     Dbl_Array;
                                    YValues : in     Dbl_Array) is

      SigWidth : Integer := InpSig'Length;
      TableLen : Integer := XValues'Length;

   begin
      for I in 0 .. SigWidth-1 loop
         declare
            U    : Standard.Long_Float := InpSig(I);
            Idx  : Integer             := OutIdx(I);
            Done : Boolean             := FALSE;
         begin

            if Idx = 0 then
               Idx := 1;
            elsif Idx = TableLen then
               Idx := TableLen-1;
            end if;

            while not(Done) loop
               if U <= XValues(Idx) then
                  Idx := Idx-1;
                  if Idx = 0 then
                     Done := TRUE;
                  end if;
               elsif U > XValues(Idx+1) then
                  Idx := Idx+1;
                  if Idx = TableLen then
                     Done := TRUE;
                  end if;
               else
                  Done := TRUE;
               end if;
            end loop;

            OutIdx(I) := Idx;
            OutSig(I) := YValues(Idx);


            if Idx = 0 then
               if U > XValues(1) then
                  raise Algorithm_Error;
               end if;
            elsif Idx < TableLen then
               if not( XValues(Idx) < U and U <= XValues(Idx+1) ) then
                  raise Algorithm_Error;
               end if;
            elsif Idx = TableLen then
               if U <= XValues(TableLen) then
                  raise Algorithm_Error;
               end if;
            else
               raise Algorithm_Error;
            end if;

         end;
      end loop;
   end Left_Continuous_Lookup; -------------------------------------------------



   -- Procedure: Right_Continuous_Lookup ---------------------------------------
   -- Abstract::
   --      This procedure implements the following simple right continuous
   --      table lookup algorithm:
   --
   --                      InpSig < XValues(1)  => OutSig = YValues(0)
   --                                              OutIdx = 0
   --      XValues(1)   <= InpSig < XValues(2)  => OutSig = YValues(1)
   --                                              OutIdx = 1
   --      XValues(2)   <= InpSig < XValues(3)  => OutSig = YValues(2)
   --                                              OutIdx = 2
   --                             :
   --                             :
   --      XValues(n-1) <= InpSig < XValues(n)  => OutSig = YValues(n-1)
   --                                              OutIdx = n-1
   --      XValues(n)   <= InpSig                  OutSig = YValues(n)
   --                                              OutIdx = n
   --
   procedure Right_Continuous_Lookup(InpSig  : in     Dbl_Array;
                                     OutSig  : out    Dbl_Array;
                                     OutIdx  : in out Int_Array;
                                     XValues : in     Dbl_Array;
                                     YValues : in     Dbl_Array) is
      SigWidth : Integer := InpSig'Length;
      TableLen : Integer := XValues'Length;
   begin
      for I in 0 .. SigWidth-1 loop
         declare
            U    : Standard.Long_Float := InpSig(I);
            Idx  : Integer             := OutIdx(I);
            Done : Boolean             := FALSE;
         begin

            if Idx = 0 then
               Idx := 1;
            elsif Idx = TableLen then
               Idx := TableLen-1;
            end if;

            while not(Done) loop
               if U < XValues(Idx) then
                  Idx := Idx-1;
                  if Idx = 0 then
                     Done := TRUE;
                  end if;
               elsif U >= XValues(Idx+1) then
                  Idx := Idx+1;
                  if Idx = TableLen then
                     Done := TRUE;
                  end if;
               else
                  Done := TRUE;
               end if;
            end loop;

            OutIdx(I) := Idx;
            OutSig(I) := YValues(Idx);

            if Idx = 0 then
               if U >= XValues(1) then
                  raise Algorithm_Error;
               end if;
            elsif Idx < TableLen then
               if not( XValues(Idx) <= U and U < XValues(Idx+1) ) then
                  raise Algorithm_Error;
               end if;
            elsif Idx = TableLen then
               if U < XValues(TableLen) then
                  raise Algorithm_Error;
               end if;
            else
               raise Algorithm_Error;
            end if;

         end;
      end loop;
   end Right_Continuous_Lookup; ------------------------------------------------

end Lookup_Methods;

-- EOF: lookup_methods.adb

--------------------------------------------------------------------------------
--                                                                            --
-- File    : lookup_methods.ads                             $Revision: 1.4 $  --
-- Abstract:                                                                  --
--      Spec for lookup_methods package. See the Body file and                --
--      simple_lookup.adb for more details.                                   --
--                                                                            --
-- Author  : Murali Yeddanapudi, 15-Aug-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

package Lookup_Methods is

   Algorithm_Error : exception;

   type Int_Array is array (Integer range <>) of Integer;
   type Dbl_Array is array (Integer range <>) of Standard.Long_Float;

   procedure Left_Continuous_Lookup
     (InpSig  : in     Dbl_Array;
      OutSig  : out    Dbl_Array;
      OutIdx  : in out Int_Array;
      XValues : in     Dbl_Array;
      YValues : in     Dbl_Array);

   procedure Right_Continuous_Lookup
     (InpSig  : in     Dbl_Array;
      OutSig  : out    Dbl_Array;
      OutIdx  : in out Int_Array;
      XValues : in     Dbl_Array;
      YValues : in     Dbl_Array);

end  Lookup_Methods;

-- EOF: lookup_methods.ads

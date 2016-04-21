--------------------------------------------------------------------------------
--                                                                            --
-- File    : matrix_gain.adb                                 $Revision: 1.3 $ --
-- Abstract:                                                                  --
--      Spec for Ada S-Function: ada_matrix_gain                              --
--                                                                            --
-- Author  : Murali Yeddanapudi, 7-May-1999                                   --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with Simulink; use Simulink;

package Matrix_Gain is

   -- The "ada_" prefix for the S-Function name makes it easy to identify
   -- this example S-Function in the MATLAB workspace. Normally you would
   -- use the same name for S_FUNCTION_NAME and the package.
   S_FUNCTION_NAME : constant String := "ada_matrix_gain";

   procedure mdlInitializeSizes(S : in SimStruct);
   pragma Export(C, mdlInitializeSizes, "mdlInitializeSizes");

   procedure mdlOutputs(S : in SimStruct; TID : in Integer);
   pragma Export(C, mdlOutputs, "mdlOutputs");

end Matrix_Gain;

-- EOF: marix_gain.ads

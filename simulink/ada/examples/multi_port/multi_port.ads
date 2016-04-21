--------------------------------------------------------------------------------
--                                                                            --
-- File    : multi_port.ads                                 $Revision: 1.4 $  --
-- Abstract:                                                                  --
--      Spec for the Ada S-Function: ada_multi_port                           --
--                                                                            --
-- Author  : Murali Yeddanapudi, 7-May-1999                                   --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with Simulink; use Simulink;

package Multi_Port is

   -- The "ada_" prefix for the S-Function name makes it easy to identify
   -- this example S-Function in the MATLAB workspace. Normally you would
   -- use the same name for S_FUNCTION_NAME and the package.
   S_FUNCTION_NAME : constant String := "ada_multi_port";

   procedure mdlCheckParameters(S : in SimStruct);
   pragma Export(C, mdlCheckParameters, "mdlCheckParameters");

   procedure mdlInitializeSizes(S : in SimStruct);
   pragma Export(C, mdlInitializeSizes, "mdlInitializeSizes");

   procedure mdlStart(S : in SimStruct);
   pragma Export(C, mdlStart, "mdlStart");

   procedure mdlOutputs(S : in SimStruct; TID : in Integer);
   pragma Export(C, mdlOutputs, "mdlOutputs");

end Multi_Port;

-- EOF: multi_port.ads

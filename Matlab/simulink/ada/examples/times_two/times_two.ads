--------------------------------------------------------------------------------
--                                                                            --
-- File    : times_two.ads                                  $Revision: 1.3 $  --
-- Abstract:                                                                  --
--      Spec for the Ada S-Function: ada_times_two                            --
--                                                                            --
-- Author  : Murali Yeddanapudi, 7-May-1999                                   --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

-- The Simulink API for Ada S-Function

with Simulink; use Simulink;

package Times_Two is

   -- The S_FUNCTION_NAME has to  be defined as a constant string.  Note that
   -- the name of the  S-Function (ada_times_two) is different  from the name
   -- of this package (times_two).  We do this so that it is easy to identify
   -- this example S-Function in the MATLAB workspace. Normally you would use
   -- the same name for S_FUNCTION_NAME and the package.
   --
   S_FUNCTION_NAME : constant String := "ada_times_two";

   -- Every S-Function is required to have the "mdlInitializeSizes" method.
   -- This method needs to be exported as shown below, with the exported name
   -- being "mdlInitializeSizes".
   --
   procedure mdlInitializeSizes(S : in SimStruct);
   pragma Export(C, mdlInitializeSizes, "mdlInitializeSizes");

   procedure mdlOutputs(S : in SimStruct; TID : in Integer);
   pragma Export(C, mdlOutputs, "mdlOutputs");

end Times_Two;

-- EOF: times_two.ads

--------------------------------------------------------------------------------
--                                                                            --
-- File    : times_two.adb                                  $Revision: 1.5 $  --
-- Abstract:                                                                  --
--      Example of a simple S-function that implements y = 2 * u, where       --
--      u is the input and y is the output.                                   --
--                                                                            --
-- Author  : Murali Yeddanapudi, 07-May-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with Simulink; use Simulink;
with Ada.Exceptions; use Ada.Exceptions;

package body Times_Two is

   -- Function: mdlInitializeSizes ---------------------------------------------
   -- Abstract:
   --      Setup the input and output port attrubouts for this S-Function.
   --
   procedure mdlInitializeSizes(S : in SimStruct) is

   begin
      -- Set the input port attributes
      --
      ssSetNumInputPorts(             S, 1);
      ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
      ssSetInputPortDataType(         S, 0, SS_DOUBLE);
      ssSetInputPortDirectFeedThrough(S, 0, TRUE);
      ssSetInputPortOverWritable(     S, 0, FALSE);
      ssSetInputPortOptimizationLevel(S, 0, 3);

      -- Set the output port attributes
      --
      ssSetNumOutputPorts(            S, 1);
      ssSetOutputPortWidth(           S, 0, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(        S, 0, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 0, 3);

      -- Set the block sample time.
      ssSetSampleTime(                S, INHERITED_SAMPLE_TIME);

   exception
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlInitializeSizes. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlInitializeSizes;


   -- Function: mdlOutputs -----------------------------------------------------
   -- Abstract:
   --      Compute the S-Function's output, given its input: y = 2 * u
   --
   procedure mdlOutputs(S : in SimStruct; TID : in Integer) is

      uWidth : Integer := ssGetInputPortWidth(S,0);
      U      : array(0 .. uWidth-1) of Real_T;
      for U'Address use ssGetInputPortSignalAddress(S,0);

      yWidth : Integer := ssGetOutputPortWidth(S,0);
      Y      : array(0 .. yWidth-1) of Real_T;
      for Y'Address use ssGetOutputPortSignalAddress(S,0);

   begin
      if uWidth = 1 then
         for Idx in 0 .. yWidth-1 loop
           Y(Idx) := 2.0 * U(0);
         end loop;
      else
         for Idx in 0 .. yWidth-1 loop
           Y(Idx) := 2.0 * U(Idx);
         end loop;
      end if;

   exception
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlOutputs. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlOutputs;

end Times_Two;

-- EOF: times_two.adb

--------------------------------------------------------------------------------
--                                                                            --
-- File    : matrix_gain.adb                                $Revision: 1.5 $  --
-- Abstract:                                                                  --
--      Example Ada S-Function. This blocks implements: y = k * u, where      --
--      u is the input, k is the (matrix) gain parameter and y is the output  --
--                                                                            --
--      xxx Update to accept any data typed parameter.                        --
--                                                                            --
-- Author  : Murali Yeddanapudi, 09-Jun-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with Simulink; use Simulink;
with Ada.Exceptions; use Ada.Exceptions;

package body Matrix_Gain is

   -- Function: mdlInitializeSizes ---------------------------------------------
   -- Abstract:
   --
   --
   procedure mdlInitializeSizes(S : in SimStruct) is

      InWidth  : Integer := DYNAMICALLY_SIZED;
      OutWidth : Integer := DYNAMICALLY_SIZED;

      NumParamsPassedIn : Integer := ssGetNumParameters(S);

   begin
      -- Get Parameter Info
      if NumParamsPassedIn /= 1 then
         ssSetErrorStatus(S,"Parameter count mismatch. Expecting 1 parameter " &
                          "while " & Integer'Image(NumParamsPassedIn) &
                          " were provided in the block dialog box");
         return;
      elsif ssGetParameterNumDimensions(S,0) /= 2 or
            ssGetParameterDataType(S,0) /=  SS_DOUBLE then
         ssSetErrorStatus(S,"Parameter must be a 2D double array");
         return;
      else
         declare
            PrmDims : array(0 .. 1) of Integer;
            for PrmDims'Address use ssGetParameterDimensions(S,0);

            NumRows  : Integer := PrmDims(0);
            NumCols  : Integer := PrmDims(1);
         begin
            InWidth  := NumCols;
            OutWidth := NumRows;
         end;
      end if;

      ssSetParameterName(S, 0, "MatrixGain");
      ssSetParameterTunable(S, 0, TRUE);

      -- Set the input port attributes
      --
      ssSetNumInputPorts(             S, 1);
      ssSetInputPortWidth(            S, 0, InWidth);
      ssSetInputPortDataType(         S, 0, SS_DOUBLE);
      ssSetInputPortOptimizationLevel(S, 0, 3);
      ssSetInputPortOverWritable(     S, 0, FALSE);
      ssSetInputPortDirectFeedThrough(S, 0, TRUE);

      -- Set the output port attributes
      --
      ssSetNumOutputPorts(             S, 1);
      ssSetOutputPortWidth(            S, 0, OutWidth);
      ssSetOutputPortDataType(         S, 0, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 0, 3);

      -- Set the block sample time.
      ssSetSampleTime(S, INHERITED_SAMPLE_TIME);

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
   --                   N
   --   Implements Y = Sum  Pi * Ui
   --                  i=0
   --
   --   where Y  is the Mx1 output signal vector,
   --         Pi is the i^th column of the MxN matrix parameter and
   --         Ui is the i^th element of the Nx1 input signal vector.
   --
   procedure mdlOutputs(S : in SimStruct; TID : in Integer) is

      InpWidth : Integer := ssGetInputPortWidth(S,0);
      Input    : array(0 .. InpWidth-1) of Real_T;
      for Input'Address use ssGetInputPortSignalAddress(S,0);

      OutWidth : Integer := ssGetOutputPortWidth(S,0);
      Output   : array(0 .. OutWidth-1) of Real_T;
      for Output'Address use ssGetOutputPortSignalAddress(S,0);

      PrmWidth : Integer := ssGetParameterWidth(S,0);
      Param    : array(0 .. PrmWidth-1) of Real_T;
      for Param'Address use ssGetParameterAddress(S,0);

   begin

      for OutIdx in 0 .. OutWidth-1 loop

         Output(OutIdx) := 0.0;

         for InpIdx in 0 .. InpWidth-1 loop
            declare
              PrmIdx : Integer := OutWidth * InpIdx + OutIdx;
            begin
               Output(OutIdx) := Output(OutIdx) + Param(PrmIdx) * Input(InpIdx);
            end;
         end loop;

      end loop;

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

end Matrix_Gain;

-- EOF: matrix_gain.adb

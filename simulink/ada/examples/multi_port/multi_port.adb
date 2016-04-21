--------------------------------------------------------------------------------
--                                                                            --
-- File    : multi_port.adb                                 $Revision: 1.4 $  --
-- Abstract:                                                                  --
--      Example of a multi port Ada S-Function.                               --
--                                                                            --
-- Author  : Murali Yeddanapudi, 26-Jul-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with  Simulink; use  Simulink;
with Ada.Exceptions; use Ada.Exceptions;

package body Multi_Port is

   -- Function: mdlCheckParameters ---------------------------------------------
   -- Abstract:
   --
   --
   procedure mdlCheckParameters(S: in SimStruct) is
      NumParamsPassedIn : Integer := ssGetNumParameters(S);
   begin

      if NumParamsPassedIn /= 1 then
         ssSetErrorStatus(S,"Parameter count mismatch. Expecting 1 parameter " &
                          "while " & Integer'Image(NumParamsPassedIn) &
                          " were provided in the block dialog box");
         return;
      elsif not(ssGetParameterIsChar(S,0)) or ssGetParameterWidth(S,0) < 2 then
         ssSetErrorStatus(S, "The parameter to this S-Function must be a " &
                             "string of at least two '+' or '-' characters");
         return;
      else
         declare
            StrPrm : String := ssGetStringParameter(S,0);
         begin
            for I in StrPrm'Range loop
               if StrPrm(I) /= '+' and StrPrm(I) /= '-' then
                  ssSetErrorStatus(S,"Invalid character in string parameter: " &
                                   StrPrm);
               end if;
            end loop;
         end;
      end if;

   exception
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlCheckParameters. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlCheckParameters;


   -- Function: mdlInitializeSizes ---------------------------------------------
   -- Abstract:
   --
   --
   procedure mdlInitializeSizes(S : in SimStruct) is
      NumInputPorts : Integer := ssGetParameterWidth(S,0);
   begin

      -- The signs parameter cannot be changed during simulation
      ssSetParameterTunable(S, 0, FALSE);
      ssSetParameterName(S, 0, "Signs");

      -- Set the number of input ports and their attributes
      --
      ssSetNumInputPorts(S, NumInputPorts);
      for I in 0 .. NumInputPorts-1 loop
         ssSetInputPortWidth(            S, I, DYNAMICALLY_SIZED);
         ssSetInputPortDataType(         S, I, SS_DOUBLE);
         ssSetInputPortOptimizationLevel(S, I, 3);
         ssSetInputPortOverWritable(     S, I, FALSE);
         ssSetInputPortDirectFeedThrough(S, I, TRUE);
      end loop;

      -- Set the number of output ports and their attributes
      --
      ssSetNumOutputPorts(    S, 4);

      -- outport 1 is the sum of the inputs
      ssSetOutputPortWidth(   S, 0, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(S, 0, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 0, 3);

      -- Outport 2 is the min value of the first output
      ssSetOutputPortWidth(   S, 1, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(S, 1, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 1, 0);

      -- Outport 3 is the avg value of the first output
      ssSetOutputPortWidth(   S, 2, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(S, 2, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 2, 0);

      -- Outport 4 is the max value of the first output
      ssSetOutputPortWidth(   S, 3, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(S, 3, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 3, 0);

      -- Set the number of work vectors and their attributes
      --
      ssSetNumWorkVectors(S, 2);

      ssSetWorkVectorName(       S, 0, "Signs");
      ssSetWorkVectorWidth(      S, 0, NumInputPorts);
      ssSetWorkVectorDataType(   S, 0, SS_INT32);
      ssSetWorkVectorUsedAsState(S, 0, FALSE);

      ssSetWorkVectorName(       S, 1, "TickCounter");
      ssSetWorkVectorWidth(      S, 1, 1);
      ssSetWorkVectorDataType(   S, 1, SS_INT32);
      ssSetWorkVectorUsedAsState(S, 1, FALSE);

      -- Set the block sample time
      --
      ssSetSampleTime(S, INHERITED_SAMPLE_TIME);

      -- Allow block input ports to scalar expand
      --
      ssSetOptionInputScalarExpansion(S, TRUE);

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


   -- Function: mdlStart -------------------------------------------------------
   -- Abstract:
   --
   --
   procedure mdlStart(S : in SimStruct) is

      NumInputPorts : Integer := ssGetNumInputPorts(S);

      StrPrm : String := ssGetStringParameter(S,0);

      Signs : array(StrPrm'Range) of Integer;
      for Signs'Address use ssGetWorkVectorAddress(S, 0);

      TickCounter : Integer;
      for TickCounter'Address use ssGetWorkVectorAddress(S, 1);

      Width : Integer := ssGetOutputPortWidth(S,0);

      Y1   : array(0 .. Width-1) of Standard.Long_Float;
      for Y1'Address use ssGetOutputPortSignalAddress(S,1);
      Y2   : array(0 .. Width-1) of Standard.Long_Float;
      for Y2'Address use ssGetOutputPortSignalAddress(S,2);
      Y3   : array(0 .. Width-1) of Standard.Long_Float;
      for Y3'Address use ssGetOutputPortSignalAddress(S,3);

   begin

      for I in StrPrm'Range loop
         if StrPrm(I) = '+' then
            Signs(I) :=  1;
         else
            Signs(I) := -1;
         end if;
      end loop;

      TickCounter := 0;

      for Idx in 0 .. Width-1 loop
         -- minimum
         Y1(Idx) := Standard.Long_Float'Last;
         -- average
         Y2(Idx) := 0.0;
         -- maximum
         Y3(Idx) := Standard.Long_Float'First;
      end loop;

   exception
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlStart. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlStart;


   -- Function: mdlOutputs -----------------------------------------------------
   -- Abstract:
   --
   --
   procedure mdlOutputs(S : in SimStruct; TID : in Integer) is

      NumInputPorts : Integer := ssGetNumInputPorts(S);

      Signs : array(0 .. NumInputPorts-1) of Integer;
      for Signs'Address use ssGetWorkVectorAddress(S, 0);

      Width : Integer := ssGetOutputPortWidth(S,0);

      Y0    : array(0 .. Width-1) of Standard.Long_Float;
      for Y0'Address use ssGetOutputPortSignalAddress(S,0);
      Y1   : array(0 .. Width-1) of Standard.Long_Float;
      for Y1'Address use ssGetOutputPortSignalAddress(S,1);
      Y2   : array(0 .. Width-1) of Standard.Long_Float;
      for Y2'Address use ssGetOutputPortSignalAddress(S,2);
      Y3   : array(0 .. Width-1) of Standard.Long_Float;
      for Y3'Address use ssGetOutputPortSignalAddress(S,3);

      NumTicks : Integer;
      for NumTicks'Address use ssGetWorkVectorAddress(S, 1);

   begin

      for Idx in 0 .. Width-1 loop
         Y0(Idx) := 0.0;
      end loop;

      for InPort in 0 .. NumInputPorts-1 loop
         declare
            InpWidth : Integer := ssGetInputPortWidth(S,InPort);
            Input    : array(0 .. InpWidth-1) of Standard.Long_Float;
            for Input'Address use ssGetInputPortSignalAddress(S,InPort);

            SignVal : Standard.Long_Float := Standard.Long_Float(Signs(InPort));
         begin
            if InpWidth = 1 then
               -- Scalar expand on the input signal
               for Idx in 0 .. Width-1 loop
                  Y0(Idx) := Y0(Idx) + SignVal*Input(0);
               end loop;
            else
               -- InpWidth == OutWidth
               for Idx in 0 .. Width-1 loop
                  Y0(Idx) := Y0(Idx) + SignVal*Input(Idx);
               end loop;
            end if;
         end;
      end loop;

      if ssIsMajorTimeStep(S) then
         NumTicks := Numticks + 1;
         for Idx in 0 .. Width-1 loop
            -- minimum
            if Y1(Idx) > Y0(Idx) then
               Y1(Idx) := Y0(Idx);
            end if;
            -- average: A(n) = [(n-1)*A(n-1)+Y(n)]/n
            Y2(Idx) := ( Y0(Idx) + Standard.Long_Float(NumTicks-1) * Y2(Idx) )
              / Standard.Long_Float(NumTicks);
            -- maximum
            if Y3(Idx) < Y0(Idx) then
               Y3(Idx) := Y0(Idx);
            end if;
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

end Multi_Port;

-- EOF: multi_port.adb

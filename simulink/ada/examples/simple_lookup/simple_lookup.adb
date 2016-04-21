--------------------------------------------------------------------------------
--                                                                            --
-- File    : simple_lookup.adb                              $Revision: 1.6 $  --
-- Abstract:                                                                  --
--      Body of the Ada S-Function simple_lookup. This example S-Function     --
--      illustrates the idea of writing a "wrapper" S-Function that "wraps"   --
--      standalone Ada code (i.e., ada packages and procedures) both for      --
--      use with Simulink as an S-Function, and directly with Ada code        --
--      generated using the RTW Ada Coder.                                    --
--                                                                            --
--      For the purpose of illustration, a simple lookup table example is     --
--      implemented here as an S-Function. This S-Function takes three        --
--      parameters:                                                           --
--        Parameter 1: "Xvalues", which must be a monotonically increasing    --
--                     double vector with atleast two elements:               --
--                                                                            --
--                              -inf < X1 < X2 < ... < Xn < inf               --
--                                                                            --
--        Parameter 2: "Yvalues", which must be a double vector and it should --
--                     have one element more than the Xvalues vector:         --
--                                                                            --
--                              Y0, Y1, Y2, ..., Yn                           --
--                                                                            --
--        Parameter 3: "LookupMethod", which must be one of the two strings,  --
--                     either "left" or "right". This specifies which lookup  --
--                     method to use.                                         --
--                                                                            --
--     The two simple algoithms implemented in the package lookup_methods     --
--     allow us to make this S-function have the following functionality:     --
--                                                                            --
--     If Lookup Method == "left" then:                                       --
--                                                                            --
--                         inp <= X1  =>  out1 = y0                           --
--                  X1   < inp <= X2  =>  out1 = y1                           --
--                  X2   < inp <= X3  =>  out1 = y2                           --
--                                :                                           --
--                                :                                           --
--                  Xn-1 < inp <= Xn  =>  out1 = yn-1                         --
--                  Xn   < inp        =>  out1 = yn                           --
--                                                                            --
--     If Lookup Method == "right" then:                                      --
--                                                                            --
--                          inp < X1  =>  out1 = y0                           --
--                  X1   <= inp < X2  =>  out1 = y1                           --
--                  X2   <= inp < X3  =>  out1 = y2                           --
--                                :                                           --
--                                :                                           --
--                  Xn-1 <= inp < Xn  =>  out1 = yn-1                         --
--                  Xn   <= inp       =>  out1 = yn                           --
--                                                                            --
--                                                                            --
--    The second output port is used as an intermediate storage area by the   --
--    lookup algorithm to remember the last index into the table, this index  --
--    is used as a starting point for the search to bracket the input.        --
--                                                                            --
--    The lookup algorithms used in this S-Function are not used or related   --
--    to the actual lookup table blocks that you see in the Simulink block    --
--    library. This S-Funciton and the supporting lookup_methods package is   --
--    merely used to illustrate the functionality of Ada S-Functions.         --
--                                                                            --
-- Author  : Murali Yeddanapudi and Tom Weis, 26-Jul-1999                     --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------

with Lookup_Methods;

with Simulink; use Simulink;
with Ada.Exceptions; use Ada.Exceptions;

package body Simple_Lookup is

   X_VALUES_PRM_IDX    : constant integer := 0;
   Y_VALUES_PRM_IDX    : constant integer := 1;
   LOOKUP_MTH_PRM_IDX  : constant integer := 2;
   NUM_PARAMS_EXPECTED : constant integer := 3;


   -- Procedure: IsLookupValuesParameterValid ----------------------------------
   -- Abstract::
   --      Utility subrutine to check if the x and y table data parameters are
   --      valid.
   --
   function IsLookupValuesParameterValid
     (S : in SimStruct; PrmIdx : in Integer) return Boolean is
      NumDims : Integer := ssGetParameterNumDimensions(S, PrmIdx);
      Dims : array(0 .. NumDims-1) of Integer;
      for Dims'Address use ssGetParameterDimensions(S, PrmIdx);

      Width : Integer := SsGetParameterWidth(S, PrmIdx);
   begin
      if ( not(ssGetParameterIsDouble(S, PrmIdx)) or (NumDims /= 2) or
           (Dims(0) /= 1 and Dims(1) /= 1) or (Width < 2) ) then
         return(FALSE);
      else
         return(TRUE);
      end if;
   end IsLookupValuesParameterValid; -------------------------------------------


   -- Procedure: mdlCheckParameters --------------------------------------------
   -- Abstract::
   --      Verify that the parameter passed to the S-Function via its dialog
   --      box are okay.
   --
   procedure mdlCheckParameters(S : in SimStruct) is
      NumActParams : Integer := ssGetNumParameters(S);
   begin
      -- Expected number of parameters
      if (NumActParams /= NUM_PARAMS_EXPECTED) then
         ssSetErrorStatus(S, "Parameter count mismatch. Expecting " &
                          Integer'Image(NUM_PARAMS_EXPECTED) & " parameter " &
                          "while " & Integer'Image(NumActParams) & " were " &
                          "provided in the block dialog box");
         return;
      end if;

      -- X values parameter must be a double vector with atleast two elements.
      if not(IsLookupValuesParameterValid(S, X_VALUES_PRM_IDX)) then
         ssSetErrorStatus(S, "The X data parameter mustbe a double " &
                          "vector with atleast two elements");
         return;
      end if;

      -- Y values parameter must be a double vector with atleast two elements.
      if not(IsLookupValuesParameterValid(S, Y_VALUES_PRM_IDX)) then
         ssSetErrorStatus(S, "The Y data parameter must be a double " &
                          "vector with atleast two elements");
         return;
      end if;

      -- Lookup method must be string that is either "left" or "right"
      declare
         ErrMsg : String := "The " & Integer'Image(LOOKUP_MTH_PRM_IDX+1) &
           "rd parameter must be a string, either 'left' or 'right', that " &
           "specifies the lookup method";
      begin
         if ssGetParameterIsChar(S, LOOKUP_MTH_PRM_IDX) then
            declare
               LookupMth : String := ssGetStringParameter(S,LOOKUP_MTH_PRM_IDX);
            begin
               if (LookupMth /= "left" and LookupMth /= "right") then
                  ssSetErrorStatus(S, ErrMsg);
               end if;
            end;
         else
            ssSetErrorStatus(S, ErrMsg);
            return;
         end if;
      end;

      declare
         XLen    : Integer := ssGetParameterWidth(S, X_VALUES_PRM_IDX);
         XValues : array(1 .. XLen) of Real_T;
         for XValues'Address use ssGetParameterAddress(S, X_VALUES_PRM_IDX);

         YLen : Integer := ssGetParameterWidth(S, Y_VALUES_PRM_IDX);

      begin
         -- Y values vector must be one longer than the X values vector
         if ( XLen+1 /=  YLen ) then
            ssSetErrorStatus(S, "The Y values vector length (" &
                             Integer'Image(YLen) & ") must be one greater " &
                             "than the x values parameter vector length (" &
                             Integer'Image(XLen) & ")");
            return;
         end if;

         -- X values vector must be monotonically increasing
         for I in 1 .. XLen-1 loop
            if ( XValues(I) > XValues(I+1) ) then
               ssSetErrorStatus(S, "X values parameter values must " &
                                "be monotonically increasing");
               return;
            end if;
         end loop;
      end;
   exception
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlCheckParameters. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlCheckParameters; -----------------------------------------------------


   -- Procedure: mdlInitializeSizes --------------------------------------------
   -- Abstract::
   --      Configure this S-Function block's attrubutes.
   --
   procedure mdlInitializeSizes(S : in SimStruct) is
   begin

      -- The X and Y values can be changed during simulation
      ssSetParameterTunable(S, X_VALUES_PRM_IDX,   TRUE);
      ssSetParameterName(S, X_VALUES_PRM_IDX,   "XValues");

      ssSetParameterTunable(S, Y_VALUES_PRM_IDX,   TRUE);
      ssSetParameterName(S, Y_VALUES_PRM_IDX,   "YValues");

      -- Lookup method parameter cannot be changed once simulation starts
      ssSetParameterTunable(S, LOOKUP_MTH_PRM_IDX, FALSE);
      ssSetParameterName(S, LOOKUP_MTH_PRM_IDX, "LookupMethod");

      -- Set Size Information
      ssSetNumContStates(S, 0);

      -- This S-Function has one input port
      ssSetNumInputPorts(             S, 1);

      -- Set the input port attributes
      ssSetInputPortWidth(            S, 0, DYNAMICALLY_SIZED);
      ssSetInputPortDataType(         S, 0, SS_DOUBLE);
      ssSetInputPortDirectFeedThrough(S, 0, TRUE);
      ssSetInputPortOptimizationLevel(S, 0, 3);
      ssSetInputPortOverWritable(     S, 0, TRUE);

      -- This S-Function has two output ports
      ssSetNumOutputPorts(            S, 2);

      -- The first output port signal is the looked up table value
      ssSetOutputPortWidth(           S, 0, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(        S, 0, SS_DOUBLE);
      ssSetOutputPortOptimizationLevel(S, 0, 3);

      -- The second output port signal is the index into table corresponding to
      -- the looked up value.  In addition,  the lookup algorithm uses the last
      -- index to start search,  so the last index value has  to be persistent,
      -- hence mark this signal as not reusable
      ssSetOutputPortWidth(           S, 1, DYNAMICALLY_SIZED);
      ssSetOutputPortDataType(        S, 1, SS_INT32);
      ssSetInputPortOptimizationLevel(S, 0, 0);

      -- Set the block sample time
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
   end mdlInitializeSizes; -----------------------------------------------------


   -- Procedure: mdlStart ------------------------------------------------------
   -- Abstract::
   --      Initialize block specific data at simulation start. For this block,
   --      this involves setting the persistent output to a reasonable value.
   --      Note that we should (and need) not initialize the first output port
   --      signal because it is not persistent, and to correctly initialize it
   --      we need to know the value of the input signal, which is not available
   --      at this point.
   --
   procedure mdlStart(S : in SimStruct) is
      Y1Width : Integer := ssGetOutputPortWidth(S,1);
      Y1      : array(0 .. Y1Width-1) of Int_T;
      for Y1'Address use ssGetOutputPortSignalAddress(S,1);

      MidPoint : Integer := (ssGetParameterWidth(S,0)+1)/2;
   begin
      -- Initalize the second output port signal, which holds the
      -- index into the lookup table, to the middle of the table.
      for I in 0 .. Y1Width-1 loop
         Y1(I) := MidPoint;
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
   end mdlStart; ---------------------------------------------------------------


   -- Procedure: mdlOutputs ----------------------------------------------------
   -- Abstract::
   --      Compute the block output port signals. Note that this is just a
   --      "wrapper" function.  The actual algorithms are implemented in a
   --      seperated package "lookup_methods", which is accessed both from
   --      here and Ada code generated using the RTW Ada Code.
   --
   procedure mdlOutputs(S : in SimStruct; TID : in Integer) is
      BlockWidth : Integer := ssGetInputPortWidth(S,0);

      U  : array(0 .. BlockWidth-1) of Standard.Long_Float;
      for U'Address use ssGetInputPortSignalAddress(S,0);

      Y0 : array(0 .. BlockWidth-1) of Standard.Long_Float;
      for Y0'Address use ssGetOutputPortSignalAddress(S,0);

      Y1 : array(0 .. BlockWidth-1) of Integer;
      for Y1'Address use ssGetOutputPortSignalAddress(S,1);

      TableLength : Integer := ssGetParameterWidth(S, X_VALUES_PRM_IDX);

      XVal  : array(1 .. TableLength) of Standard.Long_Float;
      for XVal'Address use ssGetParameterAddress(S, X_VALUES_PRM_IDX);

      YVal  : array(0 .. TableLength) of Standard.Long_Float;
      for YVal'Address use ssGetParameterAddress(S, Y_VALUES_PRM_IDX);

      LookupMth : String := ssGetStringParameter(S, LOOKUP_MTH_PRM_IDX);
   begin

      if LookupMth = "left" then
         Lookup_Methods.Left_Continuous_Lookup(Lookup_Methods.Dbl_Array(U),
                                               Lookup_Methods.Dbl_Array(Y0),
                                               Lookup_Methods.Int_Array(Y1),
                                               Lookup_Methods.Dbl_Array(XVal),
                                               Lookup_Methods.Dbl_Array(YVal));
      elsif LookupMth = "right" then
         Lookup_Methods.Right_Continuous_Lookup(Lookup_Methods.Dbl_Array(U),
                                                Lookup_Methods.Dbl_Array(Y0),
                                                Lookup_Methods.Int_Array(Y1),
                                                Lookup_Methods.Dbl_Array(XVal),
                                                Lookup_Methods.Dbl_Array(YVal));
      else
         ssSetErrorStatus(S, "Unexpected parameter value " & LookupMth &
                          " encountered in mdlOutputs");
      end if;

   exception
      when Lookup_Methods.Algorithm_Error =>
         ssSetErrorStatus(S, "Algorithmic error in Lookup_Methods");
      when E : others =>
         if ssGetErrorStatus(S) = "" then
            ssSetErrorStatus(S,
                             "Exception occured in mdlOutputs. " &
                             "Name: " & Exception_Name(E) & ", " &
                             "Message: " & Exception_Message(E) & " and " &
                             "Information: " & Exception_Information(E));
         end if;
   end mdlOutputs; -------------------------------------------------------------

end Simple_Lookup;

-- EOF: simple_lookup.adb

--------------------------------------------------------------------------------
--                                                                            --
-- File    : simulink.adb                                   $Revision: 1.6 $  --
-- Abstract:                                                                  --
--      Simulink API for Ada S-Functions                                      --
--                                                                            --
-- Author  : Murali Yeddanapudi, 07-May-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------


with System;
with Interfaces.C.Strings; use Interfaces.C.Strings;

with Simulink; use Simulink;

package Body Simulink is

   -----------------------------------------------------------------------------
   -- ssIsMajorTimeStep
   --
   --
   function  ssIsMajorTimeStep(S : in SimStruct) return Boolean is

      function slIsMajorTimeStep(S : in SimStruct) return Integer;
      pragma Import(C, slIsMajorTimeStep, "slIsMajorTimeStep");

   begin
      if (slIsMajorTimeStep(S) = 0) then
         return false;
      else
         return true;
      end if;
   end ssIsMajorTimeStep;


   -----------------------------------------------------------------------------
   -- ssG[S]etErrorStatus
   --
   --
   function ssGetErrorStatus(S : in SimStruct) return String is

      function slGetErrorStatus(S : in SimStruct) return chars_ptr;
      pragma Import(C, slGetErrorStatus, "slGetErrorStatus");

      ErrMsg : chars_ptr;
   begin
      ErrMsg := slGetErrorStatus(S);
      if ErrMsg = Null_Ptr then
         return "";
      else
         return Value(ErrMsg);
      end if;
   end ssGetErrorStatus;

   procedure ssSetErrorStatus(S : in SimStruct; ErrMsg : in String) is

      procedure slSetErrorStatus(S : in SimStruct; Msg : in chars_ptr);
      pragma Import(C, slSetErrorStatus, "slSetErrorStatus");

      cErrMsg : chars_ptr;
   begin
      cErrMsg := New_String(ErrMsg);
      slSetErrorStatus(S, cErrMsg);
      Free(cErrMsg);
   end ssSetErrorStatus;


   -----------------------------------------------------------------------------
   -- ssDisplayMessage
   --
   --
   procedure ssDisplayMessage(Msg : in String) is

      procedure slDisplayMessage(Msg : in chars_ptr);
      pragma Import(C, slDisplayMessage, "slDisplayMessage");

      cMsg : chars_ptr;
   begin
      cMsg := New_String(Msg);
      slDisplayMessage(cMsg);
      Free(cMsg);
   end ssDisplayMessage;


   -----------------------------------------------------------------------------
   -- ssGetPath
   --
   --
   function ssGetPath(S : in SimStruct) return String is

      function slGetPath(S : in SimStruct) return chars_ptr;
      pragma Import(C, slGetPath, "slGetPath");

      Path : chars_ptr;
   begin
      Path := slGetPath(S);
      if Path = Null_Ptr then
         return "";
      else
         return Value(Path);
      end if;
   end ssGetPath;


   -----------------------------------------------------------------------------
   -- ssSetSampleTime
   --
   --
   procedure ssSetSampleTime
     (S      : in SimStruct;
      Period : in time_T;
      Offset : in time_T := 0.0) is

      function slSetSampleTime(S      : in SimStruct;
                               Period : in time_T;
                               Offset : in time_T) return Integer;
      pragma Import(C, slSetSampleTime, "slSetSampleTime");

      Status : Integer;
   begin
      Status := slSetSampleTime(S, Period, Offset);
      if Status = 0 then
         ssSetErrorStatus(S,"Unable to set sample time");
         raise ssSetSampleTime_Error;
      end if;
   end ssSetSampleTime;


   -----------------------------------------------------------------------------
   -- ssSetOptionInputScalarExpansion
   --
   --
   procedure ssSetOptionInputScalarExpansion
     (S : in SimStruct; Value : in Boolean) is

      procedure slSetOptionInputScalarExpansion(S : in SimStruct;
                                                V : in Integer);
      pragma Import(C, slSetOptionInputScalarExpansion,
                    "slSetOptionInputScalarExpansion");
   begin
      if Value then
         slSetOptionInputScalarExpansion(S,1);
      else
         slSetOptionInputScalarExpansion(S,0);
      end if;
   end ssSetOptionInputScalarExpansion;


   -----------------------------------------------------------------------------
   -- ssSetNumInputPorts
   --
   --
   procedure ssSetNumInputPorts(S : in SimStruct; NumInputPorts : in Integer) is

      function slSetNumInputPorts(S             : in SimStruct;
                                  NumInputPorts : in Integer) return Integer;
      pragma Import(C, slSetNumInputPorts, "slSetNumInputPorts");

      Status : Integer;
   begin

      Status := slSetNumInputPorts(S, NumInputPorts);
      if Status = 0 then
         ssSetErrorStatus(S, "Unable to set number of input ports");
         raise ssSetNumInputPorts_Error;
      end if;

   end ssSetNumInputPorts;


   -----------------------------------------------------------------------------
   -- ssS[G]etInputPortDirectFeedThrough
   --
   --
   procedure ssSetInputPortDirectFeedThrough
     (S : in SimStruct; Idx : in Integer := 0; Value : in Boolean) is

      procedure slSetInputPortDirectFeedThrough
        (S : in SimStruct; Idx : in Integer; V : Integer);
      pragma Import(C, slSetInputPortDirectFeedThrough,
                    "slSetInputPortDirectFeedThrough");
   begin
      if Value then
         slSetInputPortDirectFeedThrough(S,Idx,1);
      else
         slSetInputPortDirectFeedThrough(S,Idx,0);
      end if;
   end ssSetInputPortDirectFeedThrough;

   function ssGetInputPortDirectFeedThrough
     (S : in SimStruct; Idx : in Integer := 0) return Boolean is

      function slGetInputPortDirectFeedThrough
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetInputPortDirectFeedThrough,
                    "slGetInputPortDirectFeedThrough");
   begin
      if (slGetInputPortDirectFeedThrough(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetInputPortDirectFeedThrough;


   -----------------------------------------------------------------------------
   -- ssS[G]etInputPortOverWritable
   --
   --
   procedure ssSetInputPortOverWritable
     (S : in SimStruct; Idx : in Integer := 0; Value : in Boolean) is

      procedure slSetInputPortOverWritable
        (S : in SimStruct; Idx : in Integer; V : Integer);
      pragma Import(C, slSetInputPortOverWritable,
                    "slSetInputPortOverWritable");
   begin
      if Value then
         slSetInputPortOverWritable(S,Idx,1);
      else
         slSetInputPortOverWritable(S,Idx,0);
      end if;
   end ssSetInputPortOverWritable;

   function ssGetInputPortOverWritable
     (S : in SimStruct; Idx : in Integer := 0) return Boolean is

      function slGetInputPortOverWritable
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetInputPortOverWritable,
                    "slGetInputPortOverWritable");
   begin
      if (slGetInputPortOverWritable(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetInputPortOverWritable;


   -----------------------------------------------------------------------------
   -- ssSetNumOutputPorts
   --
   --
   procedure ssSetNumOutputPorts(S              : in SimStruct;
                                 NumOutputPorts : in Integer) is

      function slSetNumOutputPorts(S             : in SimStruct;
                                   NumOutputPorts : in Integer) return Integer;
      pragma Import(C, slSetNumOutputPorts, "slSetNumOutputPorts");

      Status : Integer;
   begin

      Status := slSetNumOutputPorts(S, NumOutputPorts);
      if Status = 0 then
         ssSetErrorStatus(S, "Unable to set number of output ports");
         raise ssSetNumOutputPorts_Error;
      end if;

   end ssSetNumOutputPorts; ----------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssSetNumWorkVectors
   --
   --
   procedure ssSetNumWorkVectors(S              : in SimStruct;
                                 NumWorkVectors : in Integer) is

      function slSetNumWorkVectors(S : in SimStruct;
                                   N : in Integer) return Integer;
      pragma Import(C, slSetNumWorkVectors, "slSetNumWorkVectors");

      Status : Integer;
   begin

      Status := slSetNumWorkVectors(S, NumWorkVectors);
      if Status = 0 then
         ssSetErrorStatus(S, "Unable to set number of work vectors");
         raise ssSetNumWorkVectors_Error;
      end if;

   end ssSetNumWorkVectors;


   -----------------------------------------------------------------------------
   -- ssG[S]etWorkVectorName
   --
   --
   function ssGetWorkVectorName(S   : in SimStruct;
                                Idx : in Integer) return String is

      function slGetWorkVectorName(S   : in SimStruct;
                                   Idx : in Integer) return chars_ptr;
      pragma Import(C, slGetWorkVectorName, "slGetWorkVectorName");

      cName : chars_ptr;
   begin
      cName := slGetWorkVectorName(S,Idx);
      if cName = Null_Ptr then
         return "";
      else
         return Value(cName);
      end if;
   end ssGetWorkVectorName;

   procedure ssSetWorkVectorName(S   : in SimStruct;
                                Idx  : in Integer;
                                Name : in String) is

      function slSetWorkVectorName(S    : in SimStruct;
                                   Idx  : in Integer;
                                   Name : in chars_ptr) return Integer;
      pragma Import(C, slSetWorkVectorName, "slSetWorkVectorName");

      Status : Integer;
      cName  : chars_ptr;
   begin
      cName := New_String(Name);
      Status := slSetWorkVectorName(S, Idx, cName);
      Free(cName);

      if Status = 0 then
         ssSetErrorStatus(S,"Unable to set name '" & Name & "' of work vector");
         raise ssSetWorkVectorName_Error;
      end if;
   end ssSetWorkVectorName;


   -----------------------------------------------------------------------------
   -- ssS[G]etWorkVectorUsedAsState
   --
   --
   procedure ssSetWorkVectorUsedAsState
     (S : in SimStruct; Idx : in Integer; Value : in Boolean) is

      procedure slSetWorkVectorUsedAsState
        (S : in SimStruct; Idx : in Integer; V : Integer);
      pragma Import(C, slSetWorkVectorUsedAsState,
                    "slSetWorkVectorUsedAsState");
   begin
      if Value then
         slSetWorkVectorUsedAsState(S,Idx,1);
      else
         slSetWorkVectorUsedAsState(S,Idx,0);
      end if;
   end ssSetWorkVectorUsedAsState;

   function ssGetWorkVectorUsedAsState
     (S : in SimStruct; Idx : in Integer) return Boolean is

      function slGetWorkVectorUsedAsState
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetWorkVectorUsedAsState,
                    "slGetWorkVectorUsedAsState");
   begin
      if (slGetWorkVectorUsedAsState(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetWorkVectorUsedAsState;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsChar
   --
   --
   function ssGetParameterIsChar
     (S : in SimStruct; Idx : in Integer) return Boolean is

      function slGetParameterIsChar
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetParameterIsChar,"slGetParameterIsChar");

   begin
      if (slGetParameterIsChar(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetParameterIsChar;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsComplex
   --
   --
   function ssGetParameterIsComplex
     (S : in SimStruct; Idx : in Integer) return boolean is

      function slGetParameterIsComplex
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetParameterIsComplex,"slGetParameterIsComplex");

   begin
      if (slGetParameterIsComplex(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetParameterIsComplex;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsDouble
   --
   --
   function ssGetParameterIsDouble
     (S : in SimStruct; Idx : in Integer) return boolean is

      function slGetParameterIsDouble
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetParameterIsDouble,"slGetParameterIsDouble");

   begin
      if (slGetParameterIsDouble(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetParameterIsDouble;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsNumeric
   --
   --
   function ssGetParameterIsNumeric
     (S : in SimStruct; Idx : in Integer) return boolean is

      function slGetParameterIsNumeric
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, slGetParameterIsNumeric,"slGetParameterIsNumeric");

   begin
      if (slGetParameterIsNumeric(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetParameterIsNumeric;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsFinite
   --
   --
   function ssGetParameterIsFinite
     (S : in SimStruct; Idx : in Integer) return boolean is

      function slGetParameterIsFinite
        (S : in SimStruct; Idx : in Integer) return Integer;
      pragma Import(C, SlGetParameterIsFinite, "slGetParameterIsFinite");

   begin
      if (slGetParameterIsFinite(S, Idx) = 0) then
         return false;
      else
         return true;
      end if;
   end ssGetParameterIsFinite;


   -----------------------------------------------------------------------------
   -- ssGetStringParameter
   --
   --
   function ssGetStringParameter(S        : in SimStruct;
                                 Idx : in Integer) return String is

      function slGetStringParameter(S  : in SimStruct;
                                          Idx : in Integer) return chars_ptr;
      pragma Import(C,slGetStringParameter,"slGetStringParameter");

      cStr : chars_ptr;
   begin
      cStr := slGetStringParameter(S, Idx);
      if cStr = Null_Ptr then
         ssSetErrorStatus(S,"Unable to get string parameter");
         raise ssGetStringParameter_Error;
      else
         return Value(cStr);
      end if;
   end ssGetStringParameter;



   -- ssSetParameterTunable ----------------------------------------------------
   --
   --
   procedure ssSetParameterTunable
     (S : in SimStruct; Idx : in Integer; Value : in Boolean) is

      procedure slSetParameterTunable
        (S : in SimStruct; Idx : in Integer; V : Integer);
      pragma Import(C, slSetParameterTunable, "slSetParameterTunable");
   begin
      if Value then
         slSetParameterTunable(S,Idx,1);
      else
         slSetParameterTunable(S,Idx,0);
      end if;
   end ssSetParameterTunable;

   -----------------------------------------------------------------------------
   -- ssSetParameterName
   --
   --
   procedure ssSetParameterName(S        : in SimStruct;
                                Idx : in Integer;
                                Name     : in String) is

      function slSetParameterName(S        : in SimStruct;
                                  Idx : in Integer;
                                  cName    : in chars_ptr) return Integer;
      pragma Import(C, slSetParameterName, "slSetParameterName");

      Status : Integer;
      cName  : chars_ptr;
   begin
      cName := New_String(Name);
      Status := slSetParameterName(S, Idx, cName);
      Free(cName);

      if Status = 0 then
         ssSetErrorStatus(S,"Unable to set name '" & Name & "' of work vector");
         raise ssSetParameterName_Error;
      end if;
   end ssSetParameterName;


end Simulink;

-- EOF: simulink.adb

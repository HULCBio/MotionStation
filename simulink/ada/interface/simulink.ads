--------------------------------------------------------------------------------
--                                                                            --
-- File    : simulink.ads                                   $Revision: 1.6 $  --
-- Abstract:                                                                  --
--      Simulink API for Ada S-Functions                                      --
--                                                                            --
-- Author  : Murali Yeddanapudi, 07-May-1999                                  --
--                                                                            --
-- Copyright 1990-2002 The MathWorks, Inc.
--                                                                            --
--------------------------------------------------------------------------------


with System;
with Interfaces.C;
with Interfaces.C.Extensions;

package Simulink is

   -----------------------
   -- SimStruct Pointer --
   -----------------------

   subtype SimStruct is Interfaces.C.Extensions.void_ptr;

   -------------------------------
   -- Floating-Point Data Types --
   -------------------------------

   type Real_T is new Standard.Long_Float;
   type Real_T_Access is access all Real_T;

   type Real_T_Array is array (integer range <>) of Real_T;
   type Real_T_Matrix is array (integer range <>, Integer range <>) of Real_T;

   type Real64_T is new Standard.Long_Float;
   type Real64_T_Access is access all Real64_T;

   type Real32_T is new Standard.Float;
   type Real32_T_Access is access all Real32_T;

   subtype Time_T is Real_T;
   type Time_T_Access is access all Time_T;


   ------------------------
   -- Integer Data Types --
   ------------------------

   subtype Int_T is Integer;
   type Int_T_Access is access all Int_T;

   type Int_T_Array is array (integer range <>) of Int_T;

   type Int8_T is range -128 .. 127;
   for Int8_T'size use 8;
   type Int8_T_Access is access all Int8_T;

   type Int16_T is range -32768 .. 32767;
   for Int16_T'size use 16;
   type Int16_T_Access is access all Int16_T;

   type Int32_T is range -(2**31) .. ((2**31)-1);
   for Int32_T'size use 32;
   type Int32_T_Access is access all Int32_T;

   type Uint8_T is mod 2**8;
   for Uint8_T'size use 8;
   type Uint8_T_Access is access all Uint8_T;

   type Uint16_T is mod 2**16;
   for Uint16_T'size use 16;
   type Uint16_T_Access is access all Uint16_T;

   type Uint32_T is mod 2**32;
   for Uint32_T'size use 32;
   type Uint32_T_Access is access all Uint32_T;

   type Boolean_T is new Int8_T;
   type Boolean_T_Access is access all Boolean_T;
   type Boolean_Access is access all boolean;

   ------------------------------------
   -- Simulink Builtin Data Type Ids --
   ------------------------------------

   SS_INVALID_TYPE : constant := -10;
   SS_DYNAMIC_TYPE : constant :=  -1;
   SS_DOUBLE       : constant :=   0; -- Real64_T (also real_T)
   SS_SINGLE       : constant :=   1; -- Real32_T
   SS_INT8         : constant :=   2; -- Int8_T
   SS_UINT8        : constant :=   3; -- Uint8_T
   SS_INT16        : constant :=   4; -- Int16_T
   SS_UINT16       : constant :=   5; -- Uint16_T
   SS_INT32        : constant :=   6; -- Int32_T
   SS_UINT32       : constant :=   7; -- Uint32_T
   SS_BOOLEAN      : constant :=   8; -- Boolean

   ---------------------------------------------------------------------------
   -- Constants used to specify dynamic Widths, Data Types and Sample Times --
   ---------------------------------------------------------------------------

   DYNAMICALLY_TYPED      : constant := -1;
   DYNAMICALLY_SIZED      : constant := -1;
   INHERITED_SAMPLE_TIME  : constant := -1.0;
   CONTINUOUS_SAMPLE_TIME : constant :=  0.0;

   ----------------
   -- Exceptions --
   ----------------

   ssSetNumInputPorts_Error   : exception;
   SsSetNumOutputPorts_Error  : exception;
   SsSetNumWorkVectors_Error  : exception;
   ssSetWorkVectorName_Error  : exception;
   ssSetSampleTime_Error      : exception;
   ssSetParameterName_Error   : exception;
   ssGetStringParameter_Error : exception;



   -----------------------------------------------------------------------------
   ----------------------------- Model Attributes ------------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssGetT
   --
   -- Read Only Attribute.
   --
   function  ssGetT(S : in SimStruct) return Real_T;
   pragma Import(C, ssGetT, "slGetT");


   -----------------------------------------------------------------------------
   -- ssGetTStart
   --
   -- Read Only Attribute.
   --
   function  ssGetTStart(S : in SimStruct) return Real_T;
   pragma Import(C, ssGetTStart, "slGetTStart");


   -----------------------------------------------------------------------------
   -- ssGetTFinal
   --
   -- Read Only Attribute.
   --
   function  ssGetTFinal(S : in SimStruct) return Real_T;
   pragma Import(C, ssGetTFinal, "slGetTFinal");


   -----------------------------------------------------------------------------
   -- ssIsMajorTimeStep
   --
   -- Read Only Attribute.
   --
   function  ssIsMajorTimeStep(S : in SimStruct) return Boolean;


   -----------------------------------------------------------------------------
   -- ssG[S]etErrorStatus
   --
   -- Read Write Attribute.
   --
   function  ssGetErrorStatus(S : in SimStruct) return String;
   procedure ssSetErrorStatus(S : in SimStruct; ErrMsg : in String);


   -----------------------------------------------------------------------------
   -- ssDisplayMessage
   --
   procedure ssDisplayMessage(Msg : in String);


   -----------------------------------------------------------------------------
   ----------------------------- Block Attributes ------------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssGetPath
   --
   -- Read Only Attribute.
   --
   function  ssGetPath(S : in SimStruct) return String;


   -----------------------------------------------------------------------------
   -- ssG[S]etSampleTime
   --
   -- Read Write Attribute.
   --
   function  ssGetSampleTimePeriod(S : in SimStruct) return time_T;
   pragma Import(C, ssGetSampleTimePeriod, "slGetSampleTimePeriod");

   function  ssGetSampleTimeOffset(S : in SimStruct) return time_T;
   pragma Import(C, ssGetSampleTimeOffset, "slGetSampleTimeOffset");

   procedure ssSetSampleTime
     (S      : in SimStruct;
      Period : in time_T;
      Offset : in time_T := 0.0);


   -----------------------------------------------------------------------------
   -- ssSetOptionInputScalarExpansion
   --
   -- Write Only Attribute
   --
   procedure ssSetOptionInputScalarExpansion
     (S : in SimStruct; Value : in Boolean);


   -----------------------------------------------------------------------------
   ----------------------------- Continuous States -----------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssG[S]etNumContStates
   --
   -- Read Write Attribute
   --
   function  ssGetNumContStates(S : in SimStruct) return Integer;
   pragma Import(C, ssGetNumContStates, "slGetNumContStates");

   procedure ssSetNumContStates(S : in SimStruct; NumContStates : in Integer);
   pragma Import(C, ssSetNumContStates, "slSetNumContStates");


   -----------------------------------------------------------------------------
   -- ssGetContStateAddress
   --
   -- Read Only Attribute
   --
   function  ssGetContStateAddress(S : in SimStruct) return System.Address;
   pragma Import(C, ssGetContStateAddress, "slContStateAddress");


   -----------------------------------------------------------------------------
   -------------------------------- Input Ports --------------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssG[S]etNumInputPorts
   --
   -- Read Write Attribute
   --
   function  ssGetNumInputPorts(S : in SimStruct) return Integer;
   pragma Import(C, ssGetNumInputPorts, "slGetNumInputPorts");

   procedure ssSetNumInputPorts(S : in SimStruct; NumInputPorts : in Integer);


   -----------------------------------------------------------------------------
   -- ssG[S]etInputPortWidth
   --
   -- Read Write Attribute
   --
   function  ssGetInputPortWidth
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetInputPortWidth, "slGetInputPortWidth");

   procedure ssSetInputPortWidth
     (S : in SimStruct; Idx : in Integer := 0; Width : in Integer);
   pragma Import(C, ssSetInputPortWidth, "slSetInputPortWidth");


   -----------------------------------------------------------------------------
   -- ssG[S]etInputPortDataType
   --
   -- Read Write Attribute
   --
   function  ssGetInputPortDataType
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetInputPortDataType, "slGetInputPortDataType");

   procedure ssSetInputPortDataType
     (S : in SimStruct; Idx : in Integer := 0; DataType : in Integer);
   pragma Import(C, ssSetInputPortDataType, "slSetInputPortDataType");


   -----------------------------------------------------------------------------
   -- ssG[S]etInputPortDirectFeedThrough
   --
   -- Read Write Attribute
   --
   function  ssGetInputPortDirectFeedThrough
     (S : in SimStruct; Idx : in Integer := 0) return Boolean;

   procedure ssSetInputPortDirectFeedThrough
     (S : in SimStruct; Idx : in Integer := 0; Value : in Boolean);


   -----------------------------------------------------------------------------
   -- ssG[S]etInputPortOptimizationLevel
   --
   -- Level 0: Persistent (=> not Reused) and Global (=> not Local)
   --       1: Persistent (=> not Reused) and Local (=> not Global)
   --       2: Reused (=> not Persistent) and Global (=> not Local)
   --       3: Reused (=> not Persistent) and Local (=> not Global)
   --
   -- Level 0 is no optimization and 3 is full optimization.
   --
   function  ssGetInputPortOptimizationLevel
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetInputPortOptimizationLevel,
                 "slGetInputPortOptimizationLevel");

   procedure ssSetInputPortOptimizationLevel
     (S : in SimStruct; Idx : in Integer := 0; Value : in Integer);
   pragma Import(C, ssSetInputPortOptimizationLevel,
                 "slSetInputPortOptimizationLevel");


   -----------------------------------------------------------------------------
   -- ssG[S]etInputPortOverWritable
   --
   -- Read Write Attribute
   --
   function  ssGetInputPortOverWritable
     (S : in SimStruct; Idx : in Integer := 0) return Boolean;

   procedure ssSetInputPortOverWritable
     (S : in SimStruct; Idx : in Integer := 0; Value : in Boolean);


   -- ssGetInputPortSignalAddress ---------------------------------------------
   --
   -- Read Only Attribute
   --
   function  ssGetInputPortSignalAddress
     (S : in SimStruct; Idx : in Integer := 0) return System.Address;
   pragma Import(C,ssGetInputPortSignalAddress,"slGetInputPortSignalAddress");



   -----------------------------------------------------------------------------
   -------------------------------- Output Ports -------------------------------
   -----------------------------------------------------------------------------



   -----------------------------------------------------------------------------
   -- ssG[S]etNumOutputPorts
   --
   -- Read Write Attribute
   --
   function  ssGetNumOutputPorts(S : in SimStruct) return Integer;
   pragma Import(C, ssGetNumOutputPorts, "ssGetNumOutputPorts");

   procedure ssSetNumOutputPorts(S : in SimStruct; NumOutputPorts : in Integer);


   -----------------------------------------------------------------------------
   -- ssG[S]etNumOutputPortWidth
   --
   -- Read Write Attribute
   --
   function  ssGetOutputPortWidth
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetOutputPortWidth, "slGetOutputPortWidth");

   procedure ssSetOutputPortWidth
     (S : in SimStruct; Idx : in Integer := 0; Width : in Integer);
   pragma Import(C, ssSetOutputPortWidth, "slSetOutputPortWidth");


   -----------------------------------------------------------------------------
   -- ssG[S]etNumOutputPortDataType
   --
   -- Read Write Attribute
   --
   function  ssGetOutputPortDataType
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetOutputPortDataType, "slGetOutputPortDataType");

   procedure ssSetOutputPortDataType
     (S : in SimStruct; Idx  : in Integer := 0; DataType : in Integer);
   pragma Import(C, ssSetOutputPortDataType, "slSetOutputPortDataType");


   -----------------------------------------------------------------------------
   -- ssG[S]etOutputPortOptimizationLevel
   --
   -- Level 0: Persistent (=> not Reused) and Global (=> not Local)
   --       1: Persistent (=> not Reused) and Local (=> not Global)
   --       2: Reused (=> not Persistent) and Global (=> not Local)
   --       3: Reused (=> not Persistent) and Local (=> not Global)
   --
   -- Level 0 is no optimization and 3 is full optimization.
   --
   function  ssGetOutputPortOptimizationLevel
     (S : in SimStruct; Idx : in Integer := 0) return Integer;
   pragma Import(C, ssGetOutputPortOptimizationLevel,
                 "slGetOutputPortOptimizationLevel");

   procedure ssSetOutputPortOptimizationLevel
     (S : in SimStruct; Idx : in Integer := 0; Level : in Integer);
   pragma Import(C, ssSetOutputPortOptimizationLevel,
                 "slSetOutputPortOptimizationLevel");


   -----------------------------------------------------------------------------
   -- ssGetOutputPortSignalAddress
   --
   -- Read Only Attribute
   --
   function  ssGetOutputPortSignalAddress
     (S : in SimStruct; Idx : in Integer) return System.Address;
   pragma Import(C,ssGetOutputPortSignalAddress,"slGetOutputPortSignalAddress");


   -----------------------------------------------------------------------------
   -------------------------------- Work Vectors -------------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssG[S]etNumWorkVectors
   --
   -- Read Write Attribute
   --
   function  ssGetNumWorkVectors(S : in SimStruct) return Integer;
   pragma Import(C, ssGetNumWorkVectors, "slGetNumWorkVectors");

   procedure ssSetNumWorkVectors(S : in SimStruct; NumWorkVectors : in Integer);


   -----------------------------------------------------------------------------
   -- ssG[S]etWorkVectorWidth
   --
   -- Read Write Attribute
   --
   function  ssGetWorkVectorWidth
     (S : in SimStruct; Idx : in Integer) return Integer;
   pragma Import(C, ssGetWorkVectorWidth, "slGetWorkVectorWidth");

   procedure ssSetWorkVectorWidth
     (S : in SimStruct; Idx : in Integer; Width : in Integer);
   pragma Import(C, ssSetWorkVectorWidth, "slSetWorkVectorWidth");


   -----------------------------------------------------------------------------
   -- ssG[S]etWorkVectorDataType
   --
   -- Read Write Attribute
   --
   function  ssGetWorkVectorDataType
     (S : in SimStruct; Idx : in Integer) return Integer;
   pragma Import(C, ssGetWorkVectorDataType, "slGetWorkVectorDataType");

   procedure ssSetWorkVectorDataType
     (S : in SimStruct; Idx : in Integer; dType : in Integer);
   pragma Import(C, ssSetWorkVectorDataType, "slSetWorkVectorDataType");


   -----------------------------------------------------------------------------
   -- ssG[S]etWorkVectorName
   --
   -- Read Write Attribute
   --
   function  ssGetWorkVectorName
     (S : in SimStruct; Idx : in Integer) return String;

   procedure ssSetWorkVectorName
     (S : in SimStruct; Idx  : in Integer; Name : in String);


   -----------------------------------------------------------------------------
   -- ssG[S]etWorkVectorUsedAsState
   --
   -- Read Write Attribute
   --
   function  ssGetWorkVectorUsedAsState
     (S : in SimStruct; Idx : in Integer) return Boolean;

   procedure ssSetWorkVectorUsedAsState
     (S : in SimStruct; Idx : in Integer; Value : in Boolean);


   -----------------------------------------------------------------------------
   -- ssGetWorkVectorAddress
   --
   -- Read Only Attribute
   --
   function  ssGetWorkVectorAddress
     (S : in SimStruct; Idx : in Integer) return System.Address;
   pragma Import(C, ssGetWorkVectorAddress, "slGetWorkVectorAddress");


   -----------------------------------------------------------------------------
   -------------------------------- Parameters ---------------------------------
   -----------------------------------------------------------------------------


   -----------------------------------------------------------------------------
   -- ssGetNumParameters
   --
   -- Read Only Attribute
   --
   function ssGetNumParameters
     (S : in SimStruct) return Integer;
   pragma Import(C, ssGetNumParameters, "slGetNumParameters");


   -----------------------------------------------------------------------------
   -- ssGetParameterWidth
   --
   -- Read Only Attribute
   --
   function ssGetParameterWidth
     (S : in SimStruct; Idx : in Integer) return Integer;
   pragma Import(C, ssGetParameterWidth, "slGetParameterWidth");


   -----------------------------------------------------------------------------
   -- ssGetParameterDataType
   --
   -- Read Only Attribute
   --
   function ssGetParameterDataType
     (S : in SimStruct; Idx : in Integer) return Integer;
   pragma Import(C, ssGetParameterDataType, "slGetParameterDataType");


   -----------------------------------------------------------------------------
   -- ssGetParameterNumDimensions
   --
   -- Read Only Attribute
   --
   function ssGetParameterNumDimensions
     (S : in SimStruct; Idx : in Integer) return Integer;
   pragma Import(C, ssGetParameterNumDimensions, "slGetParameterNumDimensions");


   -----------------------------------------------------------------------------
   -- ssGetParameterDimensions
   --
   -- Read Only Attribute
   --
   function ssGetParameterDimensions
     (S : in SimStruct; Idx : in Integer) return System.Address;
   pragma Import(C, ssGetParameterDimensions, "slGetParameterDimensions");


   -----------------------------------------------------------------------------
   -- ssGetParameterAddress
   --
   -- Read Only Attribute
   --
   function ssGetParameterAddress
     (S : in SimStruct; Idx : in Integer) return System.Address;
   pragma Import(C, ssGetParameterAddress, "slGetParameterAddress");


   -----------------------------------------------------------------------------
   -- ssGetParameterIsChar
   --
   -- Read Only Attribute
   --
   function ssGetParameterIsChar
     (S : in SimStruct; Idx : in Integer) return Boolean;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsComplex
   --
   -- Read Only Attribute
   --
   function ssGetParameterIsComplex
     (S : in SimStruct; Idx : in Integer) return Boolean;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsDouble
   --
   -- Read Only Attribute
   --
   function ssGetParameterIsDouble
     (S : in SimStruct; Idx : in Integer) return Boolean;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsFinite
   --
   -- Read Only Attribute
   --
   function ssGetParameterIsFinite
     (S : in SimStruct; Idx : in Integer) return Boolean;


   -----------------------------------------------------------------------------
   -- ssGetParameterIsNumeric
   --
   -- Read Only Attribute
   --
   function ssGetParameterIsNumeric
     (S : in SimStruct; Idx : in Integer) return Boolean;


   -- ssGetStringParameter -----------------------------------------------------
   --
   -- Read Only Attribute
   --
   function ssGetStringParameter
     (S : in SimStruct; Idx : in Integer) return String;


   -----------------------------------------------------------------------------
   -- ssSetParameterTunable
   --
   -- Write Only Attribute
   --
   procedure ssSetParameterTunable
     (S : in SimStruct; Idx : in Integer; Value : in Boolean);


   -----------------------------------------------------------------------------
   -- ssSetParameterName
   --
   -- Write Only Attribute
   --
   procedure ssSetParameterName
     (S : in SimStruct; Idx : in Integer; Name : in String);

end Simulink;

-- EOF: simulink.ads

function dTypeID = dspCalcSLBuiltinDataTypeID(blk,dtInfo)
%dTypeID = dspCalcSLBuiltinDataTypeID(blk,dtInfo)
%   blk    : name of fixed-point enabled block
%   dtInfo : structure from dspGetDataTypeInfo for blk
%  
%   Calculates the Simulink built-in data type ID for the block, if 
%   applicable; returns -1 if the block is in back-propagation mode, or -2 if the data
%   type is not built-in, or -3 if the block is in 'same as input' mode (Const Ramp)
%  
%   NOTE: this function assumes that the following parameters exist in the
%   block:
%   
%   dataType : A popup listing the supported builtin data types as well 
%              as 'Fixed-point' and 'User-defined'
%   
%   NOTE: This function should only be called when the dataType mask parameters
%   is VISIBLE (i.e., the 'Show additional parameters' box is checked).  If
%   not, then it will return the values of the last applied settings, not
%   necessarily the last chosen settings.
%
%   NOTE: This is a Signal Processing Blockset mask utility function.  It is not intended
%   to be used as a general-purpose function.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.5 $  $Date: 2004/04/12 23:05:40 $

  UNKNOWN       = -4;
  SAME_AS_INPUT = -3;
  NOT_BUILTIN   = -2;
  INHERITED     = -1;
  SS_DOUBLE     = 0;
  SS_SINGLE     = 1;
  SS_INT8       = 2;
  SS_UINT8      = 3;
  SS_INT16      = 4;
  SS_UINT16     = 5;
  SS_INT32      = 6;
  SS_UINT32     = 7;
  SS_BOOLEAN    = 8;
  
  dtSetting = get_param(blk,'dataType');
  if ~strcmp(dtSetting,'Fixed-point') && ~strcmp(dtSetting,'User-defined') ...
        && ~strcmp(dtSetting,'Inherit via back propagation') ...
        && ~strcmp(dtSetting,'Same as input')
    className = upper(dtSetting);
  elseif strcmp(dtSetting,'Fixed-point')
    className = 'FIXEDPOINT';
  elseif strcmp(dtSetting,'User-defined')
    className = upper(localGetCategory(dtInfo.DataType));
    if isempty(className)
      % error in edit box
      dTypeID = UNKNOWN;
      return;
    end
  elseif strcmp(dtSetting,'Same as input')
    dTypeID = SAME_AS_INPUT;
    return;
  else % 'back-prop'
    dTypeID = INHERITED;
    return;
  end

  %WordLength
  switch(className)
   case 'DOUBLE'
    dTypeID = SS_DOUBLE;
   case 'SINGLE'
    dTypeID = SS_SINGLE;
   case 'BOOLEAN'
    dTypeID = SS_BOOLEAN;
   case 'FLOAT'
    if (dtInfo.DataType.MantBits == 23) && (dtInfo.DataType.ExpBits == 8)
      dTypeID = SS_SINGLE;
    elseif (dtInfo.DataType.MantBits == 52) && (dtInfo.DataType.ExpBits == 11)
      dTypeID = SS_DOUBLE;
    else
      dTypeID = NOT_BUILTIN;
    end
   otherwise
    if ~isempty(dtInfo.DataTypeWordLength) && ...
       ~isempty(dtInfo.DataTypeFracOrMantBits) && ...
       any(dtInfo.DataTypeWordLength == [8,16,32]) && ...
       dtInfo.DataTypeFracOrMantBits == 0
      if (dtInfo.DataTypeIsSigned)
        uStr = '';
      else
        uStr = 'U';
      end
      dTypeID = eval(['SS_' uStr 'INT' num2str(dtInfo.DataTypeWordLength)]);
    else
      dTypeID = NOT_BUILTIN;
    end
  end

function category = localGetCategory(dtObject)

  if strcmp(class(dtObject),'Simulink.NumericType')
    category = dtObject.Category;
  elseif isfield(dtObject,'Class')
    category = dtObject.Class;
  else
    category = [];
  end

  
  

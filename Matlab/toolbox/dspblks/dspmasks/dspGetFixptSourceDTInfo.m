function dtInfo = dspGetFixptSourceDTInfo(obj,supportsUnsigned,maxVal)
%dtInfo = dspGetFixptSourceDTInfo(obj,maxVal)
%
%   obj    : block object.
%   supportsUnsigned : non-zero indicates block can output unsigned
%                      data types; in practicaal terms, there is a 
%                      'Signed' checkbox under 'Fixed-point'.  Default
%                      value is 1.
%   maxVal : value used to calculate number of fractional bits in the
%            'best precision' case.  Default value is -1.
%   
%   This function will return a structure containing information about
%   the blocks data type.  The structure has the following fields:
%   DataTypeDeterminesFracBits : equals 1 if the data type by itself is
%                                sufficient to determine the number of 
%                                fraction bits.  This field will
%                                be 1 for builtins and for data objects
%                                whose class is not equal to FIX
%   DataTypeIsCustomFloat      : will be one for class FLOAT, except for
%                                float(32,8) and float(64,11), which are
%                                treated as single- and double-precision,
%                                respectively
%   DataTypeIsSigned           : whether or not this is a signed data type
%   DataTypeWordLength         : the total number of bits; equals -1 for
%                                boolean
%   DataTypeFracOrMantBits     : the number of fractional bits (fixed-
%                                point) or mantissa bits (floating-point)
%   DataTypeObject             : the class object returned by the sint, uint,
%                                sfrac,ufrac,sfix, ufix, and float commands,
%                                equals [] in all other cases
%   
%   NOTE: this function assumes that the following parameter variables 
%   exist in the block mask:
%   
%   dataType     : a popup listing the supported builtin data types as well 
%                  as 'Fixed-point' and 'User-defined'
%   isSigned     : a checkbox enabled when 'Fixed-point' is the selected
%                  dataType (only if supportsUnsigned ~= 0)
%   wordLen      : an edit box enabled when 'Fixed-point' is the selected
%                  dataType
%   udDataType   : an edit box enabled when 'User-defined' is the selected
%                  dataType
%   fracBitsMode : a popup with two choices: 'Best precision' and 'User-
%                  defined'
%   numFracBits  : an edit box enabled when 'User-defined' is the 
%                  fracBitsMode
%   
%   NOTE: This is a DSP Blockset mask utility function.  It is not intended
%   to be used as a general-purpose function.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 22:36:49 $

  if (nargin < 1) || isempty(obj)
    obj = get_param(gcbh,'object');
  end
  if (nargin < 2)
    supportsUnsigned = 1;
  end
  if (nargin < 3)
    maxVal = -1;
  end
  
  dtInfo.DataTypeDeterminesFracBits = 0;
  dtInfo.DataTypeIsCustomFloat      = 0;
  dtInfo.DataTypeIsSigned           = 0;
  dtInfo.DataTypeWordLength         = 2;
  dtInfo.DataTypeFracOrMantBits     = 0;
  dtInfo.DataType                   = [];

  dtSetting = obj.dataType;

  if ~strcmp(dtSetting,'Fixed-point') &&  ...
        ~strcmp(dtSetting,'User-defined') && ...
        ~strcmp(dtSetting,'Inherit via back propagation') && ...
        ~strcmp(dtSetting,'Same as input')
    className = upper(dtSetting);
  elseif strcmp(dtSetting,'Fixed-point')
    className = 'FIXEDPOINT';
  elseif strcmp(dtSetting,'User-defined')
    dtInfo.DataType = dspGetEditBoxParamValue(obj.handle,'udDataType');
    if isempty(dtInfo.DataType)
      %garbage in = garbage out
      return
    end

    if strcmp(class(dtInfo.DataType),'Simulink.NumericType')
      %
      % BOOLEAN
      % DOUBLE
      % SINGLE                               
      % FIXED-POINT: UNSPECIFIED SCALING     
      % FIXED-POINT: BINARY POINT SCALING
      % FIXED-POINT: SLOPE AND BIAS SCALING  
      %    Note: even if category is slope and bias, 
      %    the actual bias may be zero and the 
      %    actual slope a power of two
      %
      className = upper(dtInfo.DataType.Category);
    else
      if ~isfield(dtInfo.DataType,'Class')
        dtInfo.DataType = [];
        return;
      end
      className = dtInfo.DataType.Class;
    end
  else
    % This is 'inherit via back-prop' or 'same as input' - just return, we're not 
    % getting any useful info
    return
  end
  
  %DeterminesFracBits
  if strcmp(dtSetting,'User-defined')
    dtInfo.DataTypeDeterminesFracBits = dspDataTypeDeterminesFracBits(obj.udDataType);
  elseif strcmp(dtSetting,'Fixed-point')
    dtInfo.DataTypeDeterminesFracBits = 0;
  else
    dtInfo.DataTypeDeterminesFracBits = 1;
  end
      
  %IsCustomFloat
  switch(className)
   case 'FLOAT'
    % (23,8) == SINGLE and (52,11) == DOUBLE
    if (dtInfo.DataType.MantBits==23 && dtInfo.DataType.ExpBits==8) || ...
          (dtInfo.DataType.MantBits==52 && dtInfo.DataType.ExpBits==11)
      dtInfo.DataTypeIsCustomFloat = 0;
    else
      dtInfo.DataTypeIsCustomFloat = 1;
    end
   otherwise
    dtInfo.DataTypeIsCustomFloat   = 0;
  end
  
  %IsSigned
  switch(className)
   case {'DOUBLE','SINGLE','INT8','INT16','INT32','FLOAT'}
    dtInfo.DataTypeIsSigned = 1;
   case {'UINT8','UINT16','UINT32','BOOLEAN'}
    dtInfo.DataTypeIsSigned = 0;
   case {'INT','FRAC','FIX', ...
         'FIXED-POINT: BINARY POINT SCALING', ...
         'FIXED-POINT: SLOPE AND BIAS SCALING', ...
         'FIXED-POINT: UNSPECIFIED SCALING' }
    dtInfo.DataTypeIsSigned = double(dtInfo.DataType.IsSigned);
   case 'FIXEDPOINT'
    if ~supportsUnsigned || strcmpi(obj.isSigned,'on')
      dtInfo.DataTypeIsSigned = 1;
    else
      dtInfo.DataTypeIsSigned = 0;
    end
  end

  %WordLength
  switch(className)
   case 'DOUBLE'
    dtInfo.DataTypeWordLength = 64;
   case 'SINGLE'             
    dtInfo.DataTypeWordLength = 32;
   case {'INT8','UINT8'}              
    dtInfo.DataTypeWordLength = 8;
   case {'INT16','UINT16'}             
    dtInfo.DataTypeWordLength = 16;
   case {'INT32','UINT32'}             
    dtInfo.DataTypeWordLength = 32;
   case 'BOOLEAN'            
    % using 1 for Boolean word length will cause an error - and it's
    % not really 1, anyways
    dtInfo.DataTypeWordLength = 4;
   case 'FLOAT'
    dtInfo.DataTypeWordLength = dtInfo.DataType.MantBits+dtInfo.DataType.ExpBits+1; 
   case {'INT','FRAC','FIX'}                
    dtInfo.DataTypeWordLength = dtInfo.DataType.MantBits;
   case {'FIXED-POINT: BINARY POINT SCALING', ...
         'FIXED-POINT: SLOPE AND BIAS SCALING', ...
         'FIXED-POINT: UNSPECIFIED SCALING' }
    dtInfo.DataTypeWordLength = dtInfo.DataType.TotalBits;
   case 'FIXEDPOINT'
    dtInfo.DataTypeWordLength = dspGetEditBoxParamValue(obj.handle,'wordLen');
  end

  %FracOrMantBits
  switch(className)
   case 'DOUBLE'
    dtInfo.DataTypeFracOrMantBits = 52;
   case 'SINGLE'             
    dtInfo.DataTypeFracOrMantBits = 23;
   case {'INT8','UINT8','INT16','UINT16','INT32','UINT32','BOOLEAN'}            
    dtInfo.DataTypeFracOrMantBits = 0;
   case {'FLOAT','INT','FRAC','FIX', ...
         'FIXED-POINT: BINARY POINT SCALING', ...
         'FIXED-POINT: SLOPE AND BIAS SCALING', ...
         'FIXED-POINT: UNSPECIFIED SCALING' }                
    dtInfo.DataTypeFracOrMantBits = dspCalcFracOrMantBits(obj.handle, ...
                                                      dtInfo.DataType,maxVal);
   case 'FIXEDPOINT'  
    wordLen = dspGetEditBoxParamValue(obj.handle,'wordLen');
    if (isempty(wordLen))
      wordLen = 0;
    end
    dtInfo.DataTypeFracOrMantBits = dspCalcFracOrMantBits(obj.handle, ...
                                                      sfix(wordLen),maxVal);
  end

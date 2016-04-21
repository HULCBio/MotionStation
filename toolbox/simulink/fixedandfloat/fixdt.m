function [DataType,IsScaledDouble] = fixdt( varargin );
%FIXDT Create an object describing a fixed-point or floating-point data type
%
% This data type object can be passed to Simulink blocks that support 
% fixed-point data types.
%
% Usage 1: Fixed-Point Data Type With Unspecified scaling
%          Scaling would typically be determined by another block parameter.
%
%   FIXDT( Signed, WordLength )
%
% Usage 2: Fixed-Point Data Type With Binary point scaling
%
%   FIXDT( Signed, WordLength, FractionLength )
%
% Usage 3: Slope and Bias scaling
%
%   FIXDT( Signed, WordLength, TotalSlope, Bias )
%  or
%   FIXDT( Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias )
%
% Usage 4: Data Type Name String
%
%   FIXDT( DataTypeNameString )
%  or
%   [DataType,IsScaledDouble] = FIXDT( DataTypeNameString )
%     
%   The data type name string is the same string that would be displayed on 
%   signal lines in a Simulink model.  The optional setting to display port 
%   data types is found under the Simulink Format menu.
%
%   Examples using standard data types:
%
%      FIXDT('double')
%      FIXDT('single')
%      FIXDT('uint8')
%      FIXDT('uint16')
%      FIXDT('uint32')
%      FIXDT('int8')
%      FIXDT('int16')
%      FIXDT('int32')
%      FIXDT('boolean')
%
%   Key to fixed-point data type names: 
%
%      Simulink data type names are required to be valid matlab 
%      identifiers with less than 32 characters.  Fixed-point data
%      types are encoded using the following rules.
%          
%      Container
%
%        'ufix#'  unsigned with # bits  Ex. ufix3   is unsigned   3 bits
%        'sfix#'  signed   with # bits  Ex. sfix128 is signed   128 bits
%        'flts#'  scaled double data type override of sfix#
%        'fltu#'  scaled double data type override of ufix#
%
%      Number encoding
%
%        'n'      minus sign,           Ex. 'n31' equals -31
%        'p'      decimal point         Ex. '1p5' equals 1.5
%        'e'      power of 10 exponent  Ex. '125e18' equals 125*(10^(18))
%
%      Scaling Terms from the fixed-point scaling equation
% 
%           RealWorldValue = S * StoredInteger + B
%         or
%           RealWorldValue = F * 2^E * StoredInteger + B
%
%        'E'      FixedExponent           if S not given, default is 0
%        'F'      SlopeAdjustmentFactor   if S not given, default is 1
%        'S'      TotalSlope              if E not given, default is 1
%        'B'      Bias                    default 0
%
%     Examples using integers with non-standard number of bits
%
%        FIXDT('ufix1')       Unsigned  1 bit
%        FIXDT('sfix77')      Signed   77 bits
%
%     Examples using binary point scaling
%
%        FIXDT('sfix32_En31')    Fraction length 31  
%
%     Examples using slope and bias scaling
%
%        FIXDT('ufix16_S5')          TotalSlope 5 
%        FIXDT('sfix16_B7')          Bias 7
%        FIXDT('ufix16_F1p5_En50')   SlopeAdjustmentFactor 1.5  FixedExponent -50
%        FIXDT('ufix16_S5_B7')       TotalSlope 5, Bias 7
%        FIXDT('sfix8_Bn125e18')     Bias -125*10^18
%
%   Scaled Doubles
%
%     Scaled doubles data types are a testing and debugging feature.  Scaled
%     doubles occur when two conditions are met.  First, an integer or 
%     fixed-point data type is entered into a Simulink  block's mask.  Second,
%     the dominant parent subsystem has data type override setting of scaled 
%     doubles.  When this happens, a data type like 'sfix16_En7' is overridden
%     with a scaled doubles data type 'flts16_En7'.  
%        The first output of FIXDT will be the same whether the original 
%     data type 'sfix16_En7' is passed in or it's scaled doubles version
%     'flts16_En7' is passed in.  The optional second output argument 
%     is true if and only if the input is a scaled doubles data type.
%
% See also SFIX, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision $  
% $Date: 2003/11/19 21:43:22 $

IsScaledDouble = false;

DataType = Simulink.NumericType;

if nargin >= 2
    
  Signed = varargin{1} ~= 0;
  
  WordLength = varargin{2};
  
  if nargin <= 2
    
    DataType.Category = 'Fixed-point: unspecified scaling';
    
    DataType.Signed = Signed;
    
    DataType.TotalBits = WordLength;
    
  elseif nargin <= 3
    
    DataType.Category = 'Fixed-point: binary point scaling';
    
    DataType.Signed = Signed;
    
    DataType.TotalBits = WordLength;
    
    DataType.FixedExponent = -varargin{3};
    
  else
    
    DataType.Category = 'Fixed-point: slope and bias scaling';
    
    DataType.Signed = Signed;
    
    DataType.TotalBits = WordLength;
    
    if nargin <= 4
      
      TotalSlope = varargin{3};
      Bias       = varargin{4};
    else
      TotalSlope = varargin{3} * 2^varargin{4};
      Bias       = varargin{5};
    end
    
    [fff,eee] = log2( TotalSlope );
    
    fff = 2 * fff;
    eee = eee - 1;
    
    DataType.FixedExponent = eee;
    
    DataType.SlopeAdjustmentFactor = fff;
    
    DataType.Bias = Bias;
  end
  
else
  
  dataTypeNameStr = varargin{1};
  
  if ischar(dataTypeNameStr)
    
    success = 1;
    
    switch lower(dataTypeNameStr)
      
     case 'double'
      DataType.Category = 'Double';
      
     case 'single'
      DataType.Category = 'Single';
      
     case 'float'
      DataType.Category = 'Single';
      
     case 'boolean'
      DataType.Category = 'Boolean';
      
     case 'bool'
      DataType.Category = 'Boolean';
      
     case 'int32'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = true;
      DataType.TotalBits = 32;
      DataType.FixedExponent = 0;
      
     case 'int16'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = true;
      DataType.TotalBits = 16;
      DataType.FixedExponent = 0;
      
     case 'int8'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = true;
      DataType.TotalBits = 8;
      DataType.FixedExponent = 0;
      
     case 'uint32'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = false;
      DataType.TotalBits = 32;
      DataType.FixedExponent = 0;
      
     case 'uint16'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = false;
      DataType.TotalBits = 16;
      DataType.FixedExponent = 0;
      
     case 'uint8'
      DataType.Category = 'Fixed-point: binary point scaling';
      DataType.Signed = false;
      DataType.TotalBits = 8;
      DataType.FixedExponent = 0;
      
     otherwise
      
      if (strncmp(dataTypeNameStr, 'sfix', 4) | ...
          strncmp(dataTypeNameStr, 'ufix', 4) | ...
          strncmp(dataTypeNameStr, 'flt',  3))
        
        fixPtInfo = ResolveFixPtType(dataTypeNameStr);
        
        IsScaledDouble = fixPtInfo.scaledDouble ~= 0;

        if ( fixPtInfo.slope == 1 && fixPtInfo.fraction == 1 && fixPtInfo.bias == 0 )
          
          DataType.Category = 'Fixed-point: binary point scaling';
          
          DataType.Signed = fixPtInfo.signed ~= 0;
          
          DataType.TotalBits = fixPtInfo.nBits;
          
          DataType.FixedExponent = fixPtInfo.exponent;
          
        else
          
          DataType.Category = 'Fixed-point: slope and bias scaling';
          
          DataType.Signed = fixPtInfo.signed ~= 0;
          
          DataType.TotalBits = fixPtInfo.nBits;
          
          TotalSlope = fixPtInfo.slope * fixPtInfo.fraction * 2^fixPtInfo.exponent;
          
          [fff,eee] = log2( TotalSlope );
          
          fff = 2 * fff;
          eee = eee - 1;
          
          DataType.FixedExponent = eee;
          
          DataType.SlopeAdjustmentFactor = fff;
          
          DataType.Bias = fixPtInfo.bias;
          
        end
      else
        error('fixdt_construction','%s','Unrecognized data type name string.');
      end
    end
  else
    error('fixdt_construction','%s','If only one input argument is supplied to fixdt(), it must be a string.');
  end
end

function fixPtStr = ResolveFixPtType(dType)
  pos = 1;
  end_pos = length(dType);
  
  fixPtStr.signed   = 0;
  fixPtStr.slope    = 1;
  fixPtStr.fraction = 1;
  fixPtStr.exponent = 0;
  fixPtStr.bias     = 0;
  fixPtStr.scaledDouble = 0;
  fraction = 1;
  slope    = 1;
  exponent = 0;
  
  fixPtStr.slDType = '';
  prefix = '';
  
  switch dType(pos)
   case 's'
    fixPtStr.signed = 1;
    fixPtStr.dtName = dType(pos:4);
    pos = 5;
   case 'u'
    fixPtStr.signed = 0;
    fixPtStr.dtName = dType(pos:4);
    pos = 5;
    prefix = 'u';
   case 'f'
    fixPtStr.dtName = dType(pos:3);
    pos = 4;
    fixPtStr.scaledDouble = 1;
    if (dType(pos) == 's')
      fixPtStr.signed  = 1;
      fixPtStr.dtName  = 'sfix';
      pos = 5;
    elseif (dType(pos) == 'u')
      fixPtStr.dtName  = 'ufix';
      pos = 5;
      prefix = 'u';
    else
      fixPtStr.slDType = 'double';
    end
   otherwise
    error('fixdt_construction','%s','Unrecognized data type name string.');
  end
  
  sep = findstr(dType(pos:end), '_');
  
  if isempty(sep)
    next_pos = end_pos;
  else
    next_pos = pos+sep(1)-2;   
  end
   
  fixPtStr.nBits = eval(dType(pos:next_pos), 0);
  if isempty(fixPtStr.slDType)
    if fixPtStr.nBits < 2
      fixPtStr.slDType = 'boolean';
    elseif fixPtStr.nBits < 9
      fixPtStr.slDType = [prefix, 'int8'];
    elseif fixPtStr.nBits < 17
      fixPtStr.slDType = [prefix, 'int16'];
    elseif fixPtStr.nBits < 33
      fixPtStr.slDType = [prefix, 'int32'];
    else
      error(['(ResolveFixPtType) can''t handle fixpoint signals with more than 32 bit']); 
    end
  end
  
  pos = next_pos + 2;
  
  while (pos < end_pos) 
    sep = findstr(dType(pos:end), '_');
    
    if isempty(sep)
      next_pos = end_pos;
    else
      next_pos = pos+sep(1)-2;
    end 
  
    switch dType(pos)
     case 'S'
      fixPtStr.slope = ...
	  eval(strrep(strrep(dType(pos+1: next_pos),'p','.'),'n','-'));
     case 'E'
      fixPtStr.exponent = ...
	  eval(strrep(strrep(dType(pos+1: next_pos),'p','.'),'n','-'));
     case 'B'
      fixPtStr.bias = ...
	  eval(strrep(strrep(dType(pos+1: next_pos),'p','.'),'n','-'));
     case 'F'
      fixPtStr.fraction = ...
	  eval(strrep(strrep(dType(pos+1: next_pos),'p','.'),'n','-'));
     otherwise
      error(['(ResolveFixPtType) Don''t know what to do with "', dType(pos:end), '"']);
    end
    pos = next_pos + 2;
  end

  fixPtStr.dataTypeString = sprintf('%s(%d)', fixPtStr.dtName, fixPtStr.nBits);
  
  fixPtStr.scalingString = '';

  if  fixPtStr.slope ~= 1

    fixPtStr.scalingString = mat2str(fixPtStr.slope,15);
  end
  
  if fixPtStr.fraction ~= 1
    
    if isempty(fixPtStr.scalingString)
      
      fixPtStr.scalingString = mat2str(fixPtStr.fraction,15);
    else
      fixPtStr.scalingString = sprintf('%s*%s',fixPtStr.scalingString, mat2str(fixPtStr.fraction,15));
    end        
  end
  
  if fixPtStr.exponent ~= 0
    
    if isempty(fixPtStr.scalingString)
      
      fixPtStr.scalingString = sprintf('2^%d',fixPtStr.exponent );
    else
      fixPtStr.scalingString = sprintf('%s*2^%d',fixPtStr.scalingString, fixPtStr.exponent );
    end        
  end
  
  if isempty(fixPtStr.scalingString)
      
    fixPtStr.scalingString = '1';
  end        
  
  if fixPtStr.bias ~= 0
    
    fixPtStr.scalingString   = sprintf('[%s %s]', fixPtStr.scalingString, ...
                                       mat2str(fixPtStr.bias,15) );
  end

  
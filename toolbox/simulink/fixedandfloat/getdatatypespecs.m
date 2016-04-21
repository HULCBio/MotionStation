function DataTypeVec = getdatatypespecs( DataType, Scaling, DblOver, RadixGroup,returnNumericTypeObject);
%GETDATATYPESPECS is for internal use only by the Fixed Point Blockset
%
%  Combine various data type specs to form a complete specification vector
%  that is expected by Fixed Point Block S-Function
%   
%   DataTypeVec(1) = UseDbl;
%   DataTypeVec(2) = MantBits;
%   DataTypeVec(3) = IsSigned;
%   DataTypeVec(4) = FixExp;
%   DataTypeVec(5) = Slope;
%   DataTypeVec(6) = Bias;
%   DataTypeVec(7) = RadixGroup;
%

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.12.2.5 $  
% $Date: 2004/04/13 00:34:29 $

%
% default data type
%  needed to handle case when data type is specified by a variable
%  but the variable is undefined.
%
if isempty(DataType)
    DataType = uint(8);
end
%
% set indices of DataTypeVec elements
%
%    iUseDbl      = 1;
%    iMantBits    = 2;
%    iIsSigned    = 3; 
%    iFixExp      = 4;
%    iSlope       = 5;
%    iBias        = 6;
%    iRadixGroup  = 7;

% The values for the iUseDbl element MUST agree with a C enum in
% the fixedpoint module.  Currently, that enum is in a200_fixpt_types.c
% with definition.
%  typedef enum {
%
      FXP_DT_FIXPT         = 0;
      FXP_DT_SCALED_DOUBLE = 1;
      FXP_DT_DOUBLE        = 2;
      FXP_DT_SINGLE        = 3;
      FXP_DT_BOOLEAN       = 4;
      FXP_DT_CUSTOM_FLOAT  = 5;
%      
%  } fxpModeDataType;
%

% presize DataTypeVec with default choices
%    DataTypeVec(iUseDbl)     = FXP_DT_FIXPT;
%    DataTypeVec(iMantBits)   = 0;
%    DataTypeVec(iIsSigned)   = 0;
%    DataTypeVec(iFixExp)     = 0;
%    DataTypeVec(iSlope)      = 1;
%    DataTypeVec(iBias)       = 0;
%    DataTypeVec(iRadixGroup) = 0; best precision off
%
DataTypeVec = [FXP_DT_FIXPT 0 0 0 1 0 0];

% 
% handle fixpt structure
%

if isstruct(DataType)
  %
  % handle the different classes
  %
  switch DataType.Class
    %
    % handle fixed point radix OR slope-n-bias scaling
    %
   case 'FIX'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    if RadixGroup == 0
      if ~isempty(Scaling)
        [fslope,fixexp] = log2( Scaling(1) );
        fslope = fslope * 2;
        fixexp = fixexp - 1;
        DataTypeVec(4) = fixexp;
        DataTypeVec(5) = fslope;
        %
        % if second Scaling term is present it specifies the bias
        % otherwise bias stays at default of zero
        %
        if length(Scaling) > 1
          DataTypeVec(6) = Scaling(2);
        end
      end
    else
      DataTypeVec(7) = RadixGroup;
    end
    %
    % handle fixed point integer scaling
    %
   case 'INT'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    %
    % handle fixed point fractional scaling
    %
   case 'FRAC'
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = DataType.IsSigned;
    DataTypeVec(4) = DataType.IsSigned-DataType.MantBits+DataType.GuardBits;
    %
    % handle floating point doubles
    %
   case 'DOUBLE'
    DataTypeVec(1) = FXP_DT_DOUBLE;
    %
    % handle floating point singles
    %
   case 'SINGLE'
    DataTypeVec(1) = FXP_DT_SINGLE;
    %
    % handle floating point custom
    %
   case 'FLOAT'
    % USE_CUSTOM_FLOAT
    DataTypeVec(1) = FXP_DT_CUSTOM_FLOAT - 1 + DataType.ExpBits;
    DataTypeVec(2) = DataType.MantBits;
    DataTypeVec(3) = 1;
    %
    % handle error
    %
   otherwise
    disp('Warning: this class of data type is not supported')
    disp(gcb)
  end  

% else if string
elseif ischar(DataType)
  switch DataType
   
   case 'double'
    DataTypeVec(1) = FXP_DT_DOUBLE;
   
   case 'single'
    DataTypeVec(1) = FXP_DT_SINGLE;
   
   case 'boolean'
    DataTypeVec(1) = FXP_DT_BOOLEAN;
   
   case 'int32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 1;

   case 'int16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 1;
   
   case 'int8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 1;
   
   case 'uint32'
    DataTypeVec(2) = 32;
    DataTypeVec(3) = 0;
   
   case 'uint16'
    DataTypeVec(2) = 16;
    DataTypeVec(3) = 0;

   case 'uint8'
    DataTypeVec(2) = 8;
    DataTypeVec(3) = 0;
   
   otherwise
    resDataType = evalin('base', DataType);
    try
      DataTypeVec = getdatatypespecs(resDataType, Scaling, DblOver, RadixGroup);
    catch
      disp(['Error: ' DataType ' can not be used to specify the datatype'])
      disp(gcb)
    end  
  end
    
% else if Simulink.AliasType  
elseif strcmp(class(DataType), 'Simulink.AliasType')
  resDataType = evalin('base', DataType.BaseType);
  try
    DataTypeVec = getdatatypespecs(resDataType, Scaling, DblOver, RadixGroup);
  catch
    disp(['Error: ' DataType.BaseType ' does not exist in the MATLAB workspace'])
    disp(gcb)
  end  
    
% else if Simulink.NumericType  
elseif strcmp(class(DataType), 'Simulink.NumericType')
  %
  % handle the different classes
  %
  switch DataType.Category
    %
    % handle fixed point radix OR slope-n-bias scaling
    %
   case 'Fixed-point: unspecified scaling'
    DataTypeVec(2) = DataType.TotalBits;
    DataTypeVec(3) = DataType.IsSigned;
    if RadixGroup == 0
      if ~isempty(Scaling)
        [fslope,fixexp] = log2( Scaling(1) );
        fslope = fslope * 2;
        fixexp = fixexp - 1;
        DataTypeVec(4) = fixexp;
        DataTypeVec(5) = fslope;
        %
        % if second Scaling term is present it specifies the bias
        % otherwise bias stays at default of zero
        %
        if length(Scaling) > 1
          DataTypeVec(6) = Scaling(2);
        end
      end
    else
      DataTypeVec(7) = RadixGroup;
    end
    %
    % handle fixed point integer scaling
    %
   case 'Fixed-point: slope and bias scaling'
    DataTypeVec(2) = DataType.TotalBits;
    DataTypeVec(3) = DataType.IsSigned;
    DataTypeVec(4) = DataType.FixedExponent;
    DataTypeVec(5) = DataType.SlopeAdjustmentFactor;
    DataTypeVec(6) = DataType.Bias;
    %
    % handle fixed point fractional scaling
    %
   case 'Fixed-point: binary point scaling'
    DataTypeVec(2) = DataType.TotalBits;
    DataTypeVec(3) = DataType.IsSigned;
    DataTypeVec(4) = DataType.FixedExponent;
    %
    % handle floating point doubles
    %
   case 'Double'
    DataTypeVec(1) = FXP_DT_DOUBLE;
    %
    % handle floating point singles
    %
   case 'Single'
    DataTypeVec(1) = FXP_DT_SINGLE;
    %
    % handle boolean
    %
   case 'Boolean'
    DataTypeVec(1) = FXP_DT_BOOLEAN;
   otherwise
    disp('Warning: this category of data type is not supported')
    disp(gcb)
  end  
else
  disp('Warning: this category of data type is not supported')
  disp(gcb)
end

% Make sure IsSigned has value 0 or 1, not something like 73
DataTypeVec(3) = DataTypeVec(3) ~= 0;

if (DataTypeVec(1) == FXP_DT_FIXPT           || ...
    DataTypeVec(1) == FXP_DT_SCALED_DOUBLE )

    FXP_MAX_BITS = 128;
  
    if DataTypeVec(2) <= DataTypeVec(3)

      error('simulink:fixedpoint:invaliddatatype',...
            'Specified fixed-point data type is not valid.  It has too few bits.');
    
      DataTypeVec(2) = DataTypeVec(3) + 1;
      
    elseif DataTypeVec(2) > FXP_MAX_BITS

      error('simulink:fixedpoint:invaliddatatype',...
            'Specified fixed-point data type is not valid.  It has too many bits.');
      
      DataTypeVec(2) = FXP_MAX_BITS;
    end

    if DataTypeVec(5) <= 0
      
      error('simulink:fixedpoint:invaliddatatype',...
            'Specified fixed-point data type is not valid.  Slope must be strictly positive.');
      
      DataTypeVec(5) = 1;
    end
end

if nargin >= 5 && returnNumericTypeObject
  
  switch DataTypeVec(1)
    
   case FXP_DT_FIXPT

    DataTypeVec = fixdt( DataTypeVec(3), ...
                         DataTypeVec(2), ...
                         DataTypeVec(5), ...
                         DataTypeVec(4), ...
                         DataTypeVec(6));
    
   case FXP_DT_SCALED_DOUBLE
    
    error('simulink:fixedpoint:invaliddatatype',...
          'Scaled doubles cannot be represented using Simulink.NumericTypes.');

   case FXP_DT_DOUBLE

    DataTypeVec = fixdt('double');
    
   case FXP_DT_SINGLE
    
    DataTypeVec = fixdt('single');
    
   case FXP_DT_BOOLEAN
    
    DataTypeVec = fixdt('boolean');
    
   case FXP_DT_CUSTOM_FLOAT
    
    error('simulink:fixedpoint:invaliddatatype',...
          'Custom floating-point types cannot be represented using Simulink.NumericTypes.');

  end

end
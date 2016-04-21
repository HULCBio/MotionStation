function numBits = dspCalcFracOrMantBits(blk,dtObject,maxVal)
%numBits = dspCalcFracOrMantBits(blk,dtObject,maxVal)
%    blk      : block for which to calculate number of bits
%    dtObject : class object for the block (sfix(), uint(), etc)
%    maxVal   : maximum value for calls to fixptbestprec.  Default value
%               is -1.
%
%   This function calculates the number or fractional or mantissa bits when
%   the block's mask data type parameter is 'Fixed-point' or 'User-defined'
% 
%   If the block has a fixed-point data type and is set to 'Best precision',
%   then maxVal must be set.
%
%   NOTE: this function assumes that the following parameters exist in the
%   block:
%   
%   fracBitsMode : A popup with two choices: 'Best precision' and 'User-
%                  defined'
%   numFracBits  : An edit box enabled when 'User-defined' is the fracBitsMode
%   
%   NOTE: This is a Signal Processing Blockset mask utility function.  It is not intended
%   to be used as a general-purpose function.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/04/12 23:05:39 $

  if (nargin < 3)
    maxVal = -1;
  end

  className = upper(localGetCategory(dtObject));

  switch(className)
  case 'SINGLE'
    numBits = 23;
  case 'DOUBLE'
    numBits = 52;
  case 'FLOAT'
    numBits = dtObject.MantBits;
  case 'INT'
    numBits = 0;
  case 'BOOLEAN'
    numBits = 0;
  case 'FRAC'
    numBits = dtObject.MantBits - dtObject.GuardBits - dtObject.IsSigned;
  case {'FIX', ...
        'FIXED-POINT: UNSPECIFIED SCALING' }
    % If the scale param is invisible, must make it visible before accessing it
    maskParams = get_param(blk,'masknames');
    ii = find(strcmp(maskParams,'fracBitsMode'));
    vis = get_param(blk,'maskvisibilities');
    if strcmp(vis(ii),{'off'})
      vis(ii) = {'on'};
      set_param(blk,'maskvisibilities',vis);
      isBestPrec = strcmp(get_param(blk,'fracBitsMode'),'Best precision');
      vis(ii) = {'off'};
      set_param(blk,'maskvisibilities',vis);
    else
      isBestPrec = strcmp(get_param(blk,'fracBitsMode'),'Best precision');
    end
    if isBestPrec
      numBits = -fixptbestexp(maxVal,localGetTotalBits(dtObject),double(dtObject.IsSigned));
      if ~isscalar(numBits)
        numBits = min(numBits(:));
      end
    else
      % eval the fracBits edit box
      numBits = dspGetEditBoxParamValue(blk,'numFracBits');
    end
  case 'FIXED-POINT: BINARY POINT SCALING'
    numBits = -dtObject.FixedExponent;
  case 'FIXED-POINT: SLOPE AND BIAS SCALING'
    numBits = -dtObject.FixedExponent;
    if dtObject.SlopeAdjustmentFactor ~= 1.0 || ...
       dtObject.Bias ~= 0.0
      error('Signal Processing Blockset only supports fixed-point scaling with power of two slopes and zero bias.')
    end
  otherwise
    % unknown class => unknown fracbits
    numBits = NaN;
  end
  
function totalBits = localGetTotalBits(dtObject)
  
  if strcmp(class(dtObject),'Simulink.NumericType')
    totalBits = dtObject.TotalBits;
  else
    totalBits = dtObject.MantBits;
  end

function category = localGetCategory(dtObject)

  if strcmp(class(dtObject),'Simulink.NumericType')
    category = dtObject.Category;
  elseif isfield(dtObject,'Class')
    category = dtObject.Class;
  else
    category = [];
  end

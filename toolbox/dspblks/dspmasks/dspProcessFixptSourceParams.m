function [curVis,lastVis] = dspProcessFixptSourceParams(obj,dataTypeIndex,supportsUnsigned,visState,lastVisState)
%[curVis,lastVis] = dspProcessFixptMaskParams(obj,visState,addlParams)
%   blk          : block object.
%   dataTypeIndex: index of the dataType mask parameter
%   supportsUnsigned : non-zero indicates block can output unsigned
%                      data types; in practicaal terms, there is a 
%                      'Signed' checkbox under 'Fixed-point'.  Default
%                      value is 1.
%   visState     : the visibility settings at the time of this function call, 
%                  to allow the state to be updated.  If not supplied, the
%                  visibility state will be initialized by a call to
%                  get_param(blk,'maskvisibilities')
%   lastVisState : the last applied visibility settings. If not supplied, the
%                  state will be initialized to be equal to visState
%
%   This function handles the dynamic switching of parameter visibilities
%   for fixed-point enabled blocks that meet the requirements below.
%
%   This function returns two values:
%  
%   curVis  : The current set of visibility settings
%   lastVis : The last applied set of visibility settings
%
%   NOTE: This is a DSP Blockset mask utility function.  It is not intended
%   to be used as a general-purpose function.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 22:36:52 $

% source params: 
%   dataType
%   isSigned
%   wordLen
%   udDataType
%   fracBitsMode
%   numFracBits


if (nargin < 1) || isempty(obj)
  obj = get_param(gcbh,'object');
end
if (nargin < 2) || isempty(dataTypeIndex)
  DATA_TYPE = find(strcmp(obj.MaskNames,'dataType'));
else
  DATA_TYPE = dataTypeIndex;
end
if (nargin < 3)
  supportsUnsigned = 1;
end
if (nargin < 4)
  curVis  = obj.MaskVisibilities;
else
  curVis  = visState;
end
if (nargin < 5)
  lastVis = curVis;
else
  lastVis = lastVisState;
end

IS_SIGNED  = DATA_TYPE  + 1;
if supportsUnsigned
  WORD_LEN = IS_SIGNED  + 1;
else
  WORD_LEN = DATA_TYPE  + 1;
end
USER_DTYPE = WORD_LEN   + 1;
FRAC_MODE  = USER_DTYPE + 1;
FRAC_BITS  = FRAC_MODE  + 1;

dType = obj.dataType;
% 'Inherit from' is used by the DSP Constant block (Inherit from
% 'Constant value') and the Constant Diag Matrix block (Inherit
% from 'Constant(s) along diagonal')
if (any(strcmp(dType,{'double','single','int8','uint8','int16',...
                      'uint16','int32','uint32','boolean',...
                      'Inherit via back propagation', ...
                      'Same as input'})) || ...
    strncmp(dType,{'Inherit from'},12))
  curVis(IS_SIGNED:FRAC_BITS) = {'off'};
else
  if strcmp(dType,'Fixed-point')
    if supportsUnsigned
      curVis(IS_SIGNED) = {'on'}; 
    end
    curVis(WORD_LEN) = {'on'};
    curVis(FRAC_MODE) = {'on'};
    curVis(USER_DTYPE) = {'off'};
    % need to update visibility before accessing fracBitsMode
    obj.MaskVisibilities = curVis;
    lastVis = curVis;
    bestPrec = strcmp(obj.fracBitsMode,'Best precision');
    if bestPrec
      curVis(FRAC_BITS) = {'off'};
    else
      curVis(FRAC_BITS) = {'on'};
    end
  else %'User-defined'
    curVis(USER_DTYPE) = {'on'};
    if supportsUnsigned
      curVis(IS_SIGNED) = {'off'};
    end
    curVis(WORD_LEN) = {'off'};
    if dspDataTypeDeterminesFracBits(obj.udDataType)
      curVis(FRAC_MODE) = {'off'};
      curVis(FRAC_BITS) = {'off'};
    else
      curVis(FRAC_MODE) = {'on'};
      % need to update visibility before accessing fracBitsMode
      obj.MaskVisibilities = curVis;
      lastVis = curVis;
      bestPrec = strcmp(obj.fracBitsMode,'Best precision');
      if bestPrec
        curVis(FRAC_BITS) = {'off'};
      else
        curVis(FRAC_BITS) = {'on'};
      end
    end % User-defined/DataTypeDeterminesFracBits           
  end   % Fixed-point and User-defined
end     % dataType 


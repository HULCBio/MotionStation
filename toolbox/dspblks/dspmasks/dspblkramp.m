function varargout = dspblkramp(action)
% DSPBLKRAMP is the mask function for the Signal Processing Blockset Constant Ramp block

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/01/25 22:37:08 $

% Parameters: L,Slope,Offset,additionalParams,allowOverrides,
%             dataType,wordLen,udDataType,fracBitsMode,numFracBits

blk = gcbh;
obj = get_param(blk,'object');

if (nargin < 1)
  action = 'dynamic';
end

switch(action)
 case 'init'
  dtInfo = dspGetFixptSourceDTInfo(obj,1,1);
  dtID = dspCalcSLBuiltinDataTypeID(blk,dtInfo);
  varargout = {dtInfo,dtID};
 case 'dynamic'
  % Execute dynamic dialogs      
  vis = get_param(blk,'maskvisibilities');
  [vis,lastvis] = dspProcessFixptSourceParams(obj,6,1,vis);

  if (~isequal(vis,lastvis))
    set_param(blk,'maskvisibilities',vis);
  end
  
  varargout = {};
end

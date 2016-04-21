function varargout = dspblkeye(action)
% DSPBLKEYE is the mask function for the Signal Processing Blockset Identity
% Block

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.9.4.3 $ $Date: 2004/01/25 22:37:01 $

% Parameters: Inherit,N,Ts,additionalParams,dataType,
%             wordLen,udDataType,fracBitsMode,numFracBits
[N_SIZE,SAMP_TIME,SHOW_PARAMS,ALLOW_OVER] = deal(2,3,4,5);
[DATA_TYPE,WORD_LEN,USER_DT,FRAC_MODE,FRAC_BITS] = deal(6,7,8,9,10);

blk = gcbh;
obj = get_param(blk,'object');
inheritOn = strcmp(obj.Inherit,'on');

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
  vis = obj.MaskVisibilities;
  lastvis = vis;

  if inheritOn
    vis(N_SIZE)              = {'off'};
    vis(SAMP_TIME)           = {'off'};
    vis(DATA_TYPE:FRAC_BITS) = {'off'};
  else   
    vis(N_SIZE)      = {'on'};
    vis(SAMP_TIME)   = {'on'};
    vis(DATA_TYPE)   = {'on'};
    %need to update visibility before accessing additonalParams
    obj.MaskVisibilities = vis;
    [vis,lastvis] = dspProcessFixptSourceParams(obj,6,1,vis);
  end

  if (~isequal(vis,lastvis))
    obj.MaskVisibilities = vis;
  end
end

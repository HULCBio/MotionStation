function varargout = dspblkwinfcn2(action)
% DSPBLKWINFCN2 Signal Processing Blockset Window Function block helper function
% for mask parameters.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.5 $ $Date: 2004/04/12 23:07:45 $

if nargin==0, action = 'dynamic'; end
obj = get_param(gcbh,'object');

% params
[SMODE, STIME, WLEN, DB, BETA, SAMP]   = deal(3,4,5,6,7,8);
[FNAME, OPT_PARAMS, USER_PARAMS, ADDL] = deal(9,10,11,12);
[DATA_TYPE,FRAC_LEN, W_MODE, OM]       = deal(14,18,19,29);

switch action
 case 'init'
  
  [w,x,y,str]=dspblkwinfcn2get(gcbh,32);
  ports = get_labels(obj.winmode);
  dtInfo = dspGetFixptSourceDTInfo(obj);
  dtID = dspCalcSLBuiltinDataTypeID(gcbh,dtInfo);
  fixptInfo = dspGetFixptDataTypeInfo(gcbh,43);
  
  varargout = {x,y,str,ports,w,dtInfo,dtID,fixptInfo};
  
end
return

% ----------------------------------------------------------
function ports = get_labels(wmode)

% Input port labels:
switch wmode
 case 'Generate window'
  % One label on output:
  ports = struct('type','output', ...
                 'port',1, ...
                 'txt',{'','','Win'});
   
 case 'Apply window to input'
  % No labels:
  ports = struct('type',{'input','output','output'}, ...
                 'port',1, ...
                 'txt','');
  
 case 'Generate and apply window'
  % Label all ports:
  ports = struct('type',{'input','output','output'}, ...
                 'port',{1,1,2}, ...
                 'txt',{'In','Out','Win'});
end

return


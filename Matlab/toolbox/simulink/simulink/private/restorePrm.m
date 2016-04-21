function restorePrm(iParamRestoreInfo)
%
% Facilitates param save/set/restore sequences.
% Input argument intended come from saveAndSetPrm().
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  set_param(iParamRestoreInfo.mObj, ...
            iParamRestoreInfo.mPrmName, ...
            iParamRestoreInfo.mOldVal);

%endfunction restorePrm

function oParamRestoreInfo = saveAndSetPrm(iObj, iPrmName, iNewVal)
%
% Facilitates param save/set/restore sequences.
% Return value intended to be used with restorePrm().
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  oParamRestoreInfo.mObj = iObj;
  oParamRestoreInfo.mPrmName = iPrmName;
  oParamRestoreInfo.mOldVal = get_param(iObj, iPrmName);
  
  set_param(iObj, iPrmName, iNewVal);

%endfunction saveAndSetPrm

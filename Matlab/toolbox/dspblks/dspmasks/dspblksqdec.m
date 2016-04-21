function [x,y,si,so,dtInfo,dTypeID] = dspblksqdec(action)
% DSPBLKSQDEC Signal Processing Blockset Scalar quantization decoder mask helper function.
% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/20 23:16:13 $
%  

if nargin==0, action = 'dynamic'; end

blkh = gcbh;
obj = get_param(blkh,'object');

switch action
 case 'icon'
  codeVals = dspGetEditBoxParamValue(blkh,'codebook');
  dtInfo = dspGetFixptSourceDTInfo(obj,1,codeVals);    
  dTypeID = dspCalcSLBuiltinDataTypeID(blkh,dtInfo);
  x = [0.11 0.28 0.28 0.48 0.48 0.68 0.68 0.85 NaN];
  y = [0.1 0.1 0.3 0.3 0.5 0.5 0.7 0.7 NaN];
  %%%%
  
  si(1).port = 1;
  si(1).txt = 'I';
  
  if strcmp(obj.CBSource, 'Input port'),   
    si(2).port = 2;
    si(2).txt = 'C';
  else
    si(2).port = 1;
    si(2).txt = 'I';
  end  
  so(1).port = 1;
  so(1).txt = 'Q(U)';
  
 case 'dynamic'
  visibles     = obj.MaskVisibilities;
  old_visibles = visibles;
  % prefix: pu=pop-up, eb=edit box, cb=check box
  %[puCB_SRC,   puINVINP,    ebCB, ...
  % puDTYPE,    cbIS_SIGNED, ebWORD_LEN, ...
  % ebUD_DTYPE, puFRAC_MODE, ebFRAC_LEN] = deal(1,2,3,4,5,6,7,8,9);
  
  [ebCB, puDTYPE, ebFRAC_LEN] = deal(3,4,9);
  puCB_SRCstr = obj.CBsource;
  if strcmp(puCB_SRCstr,'Input port')
    visibles(ebCB:ebFRAC_LEN) = {'off'};
  else
    visibles(ebCB:puDTYPE) = {'on'};
    obj.MaskVisibilities = visibles;
    [visibles,old_visibles] = ...
        dspProcessFixptSourceParams(obj,4,1,visibles);
  end
  
  if (~isequal(visibles,old_visibles))
    obj.MaskVisibilities = visibles;
  end
end


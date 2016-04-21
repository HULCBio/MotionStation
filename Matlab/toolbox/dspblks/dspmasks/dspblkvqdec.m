function [x1,y1,x2,y2,xc,yc,si,so,dtInfo,dTypeID] = dspblkvqdec(action)
% DSPBLKVQDEC Signal Processing Blockset Vector quantization decoder block mask helper function.
% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/20 23:16:14 $
%  

if nargin==0, action = 'dynamic'; end

blkh = gcbh;
obj = get_param(blkh,'object');

switch action
case 'icon'
 codeVals = dspGetEditBoxParamValue(blkh,'codebook');
 dtInfo = dspGetFixptSourceDTInfo(obj,1,codeVals);      
 dTypeID = dspCalcSLBuiltinDataTypeID(blkh,dtInfo);
 %%Draw voronoi cells with centroids%%
    x1=[ 0.52 0.55 0.70 0.78 NaN  0.78 0.65 0.48 0.46 NaN 0.20 0.38 0.35 0.20]-0.04;
	y1=[ 0.15 0.40 0.50 0.43 NaN  0.85 0.65 0.72 0.93 NaN 0.80 0.67 0.50 0.35]-0.15;
	x2 = [x1(3) x1(7) NaN x1(8) x1(12) NaN x1(13) x1(2)];
	y2 = [y1(3) y1(7) NaN y1(8) y1(12) NaN y1(13) y1(2)];
	
	% circles
	S=8; t=(0:S)'/S*2*pi; a=0.01;
	xcos=a*cos(t);ysin=a*sin(t);
	
	xc=xcos*ones(1,7) + ones(size(t))*([.72 .80 .65 .41  0.32  0.40 0.59]-0.1);
	yc=ysin*ones(1,7) + ones(size(t))*([.30 .60 .80 .80  0.60  0.30 0.55]-0.15);

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


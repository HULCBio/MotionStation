function [x,y, si,so,disp_str,dtInfo] = dspblksqenc(action)
% DSPBLKSQENC Signal Processing Blockset Scalar quantization encoder mask helper function.
% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/01/25 22:37:11 $
%  

if nargin==0, action = 'dynamic'; end

blkh = gcbh;

switch action
case 'icon'
  dtInfo = dspGetFixptDataTypeInfo(blkh,1);   
  % graphical
  x = [0.11 0.28 0.28 0.48 0.48 0.68 0.68 0.85 NaN];
  y = [0.1 0.1 0.3 0.3 0.5 0.5 0.7 0.7 NaN];
  % string
  cbOUTQUstr       = get_param(blkh,'outQU');     % a member of ALWAYS_ON_ITEMS
  cbOUTQERRORstr   = get_param(blkh,'outQError'); % a member of ALWAYS_ON_ITEMS
  if (strcmp(cbOUTQUstr, 'on') || strcmp(cbOUTQERRORstr, 'on'))
      disp_str='  SQ Codec';
  else
      disp_str='SQ Encoder';
  end     
  % port label
  i = 1;
  j = 1;
  si(i).port = i;
  si(i).txt = 'U'; i=i+1;
  puPARAMSRCstr    = get_param(blkh,'paramSrc');  
  cbOUTQUstr       = get_param(blkh,'outQU');     % a member of ALWAYS_ON_ITEMS
  cbOUTQERRORstr   = get_param(blkh,'outQError'); % a member of ALWAYS_ON_ITEMS

  if strncmp(puPARAMSRCstr, 'Input ports',1),   
        si(i).port = i;
        si(i).txt = 'B'; i = i+1;
     if (strcmpi(cbOUTQUstr, 'on') ||strcmpi(cbOUTQERRORstr, 'on')),      
        si(i).port = i;
        si(i).txt = 'C'; i = i+1;
     end   
  end  
  
  so(j).port = j;
  so(j).txt = 'I'; j=j+1;
  if strcmpi(cbOUTQUstr, 'on')
       so(j).port = j;
       so(j).txt = 'Q(U)'; j = j+1; 
  end       
  if strcmpi(cbOUTQERRORstr, 'on')
       so(j).port = j;
       so(j).txt = 'Err'; j = j+1; 
  end   
  puPARTTYPEstr    = get_param(blkh,'partType');
  cbOUTSTATUSstr   = get_param(blkh,'outStatus'); 
  if (strncmp(puPARTTYPEstr, 'Bounded',1) && strcmpi(cbOUTSTATUSstr, 'on'))
       so(j).port = j;
       so(j).txt = 'S'; j = j+1; 
  end  
  
 
 for m=i:3, si(m)=si(i-1); end
 for n=j:4, so(n)=so(j-1); end
 
case 'dynamic'
  % Execute dynamic dialogs
  %---------------------------------------------------------------------------
  % STEP-1: snap current states of mask items
  mask_visibles     = get_param(blkh, 'MaskVisibilities');
  old_mask_visibles = mask_visibles;
  mask_enables      = get_param(blkh, 'MaskEnables');
  old_mask_enables  = mask_enables;
  %allowOverrides, roundingMode, overflowMode
   [puPARAMSRC, puPARTTYPE,ebBBOUNDARY,ebUBOUNDARY, puSEARCHMETHOD, puTIEBREAKRULE, ...
   cbOUTQU, cbOUTQERROR,ebCODEBOOK, cbOUTSTATUS,puINVALIDIN, cbADDITIONALPARAMS, puIDTYPE,...
   cbALLOWOVERRIDES, puROUNDINGMODE, cbOVERFLOWMODE] ...
    =deal(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16);

  %---------------------------------------------------------------------------
  % STEP-2:
  ALWAYS_ON_ITEMS = [puPARAMSRC puPARTTYPE puSEARCHMETHOD puTIEBREAKRULE cbOUTQU cbOUTQERROR cbADDITIONALPARAMS];
  mask_enables(ALWAYS_ON_ITEMS) = {'on'}; mask_enables(ALWAYS_ON_ITEMS) = {'on'}; 

  %---------------------------------------------------------------------------
  % STEP-3:
  % pop-ups/checkbox those control dynamics of other items (these might be
  % controlled by others)   
  puPARAMSRCstr    = get_param(blkh,'paramSrc');    % a member of ALWAYS_ON_ITEMS
  puPARTTYPEstr    = get_param(blkh,'partType');    % a member of ALWAYS_ON_ITEMS
  cbOUTQUstr       = get_param(blkh,'outQU'); % a member of ALWAYS_ON_ITEMS
  cbOUTQERRORstr   = get_param(blkh,'outQError');  % a member of ALWAYS_ON_ITEMS
  cbADDITIONALPARAMSstr = get_param(blkh,'additionalParams');  % a member of ALWAYS_ON_ITEMS
  
  %%%
  if strncmp(puPARAMSRCstr, 'Specify ...',1),
      puPARAMSRCnum = 1;     
  else % unbounded
      puPARAMSRCnum = 2;
  end 
  
  %%%
  if strncmp(puPARTTYPEstr, 'Bounded',1),
      puPARTTYPEnum = 1;
  else 
      puPARTTYPEnum = 2;     
  end       
  
  %%%
  if strcmp(cbOUTQUstr, 'on'),
      cbOUTQUnum = 1;     
  else 
      cbOUTQUnum = 2;
  end 
  %%%
  %%%
  if strcmp(cbOUTQERRORstr, 'on'),
      cbOUTQERRORnum = 1;     
  else 
      cbOUTQERRORnum = 2;
  end 
  
  %%%
  if strcmp(cbADDITIONALPARAMSstr, 'on'),
      cbADDITIONALPARAMSnum = 1;     
  else 
      cbADDITIONALPARAMSnum = 2;
  end 

  %---------------------------------------------------------------------------
  % STEP-4: any items NOT a member of ALWAYS_ON_ITEMS
  NOT_ALWAYS_ON_ITEMS =setdiff(1:16, ALWAYS_ON_ITEMS);; 
  %[ebBBOUNDARY,ebUBOUNDARY,ebCODEBOOK,cbOUTSTATUS,puIDTYPE, puIDTYPE,cbALLOWOVERRIDES,puROUNDINGMODE,cbOVERFLOWMODE];
  ebBBOUNDARYstatus = (puPARAMSRCnum == 1 && puPARTTYPEnum == 1);
  ebUBOUNDARYstatus = (puPARAMSRCnum == 1 && puPARTTYPEnum == 2);
  ebCODEBOOKstatus  = (puPARAMSRCnum == 1 && (cbOUTQUnum == 1 || cbOUTQERRORnum == 1));
  cbOUTSTATUSstatus = (puPARTTYPEnum == 1);
  puINVALIDINstatus = (puPARTTYPEnum == 1);

  puIDTYPEstatus          = (cbADDITIONALPARAMSnum == 1);
  cbALLOWOVERRIDESstatus  = 0; % permanently disable checkbox
  puROUNDINGMODEstatus    = (cbADDITIONALPARAMSnum == 1);
  cbOVERFLOWMODEstatus    = (cbADDITIONALPARAMSnum == 1);
  
  NOT_ALWAYS_ON_ITEMSstatus = [ebBBOUNDARYstatus ebUBOUNDARYstatus ebCODEBOOKstatus cbOUTSTATUSstatus ...
                               puINVALIDINstatus puIDTYPEstatus cbALLOWOVERRIDESstatus puROUNDINGMODEstatus cbOVERFLOWMODEstatus];
  mask_visibles(NOT_ALWAYS_ON_ITEMS) = {'off'}; mask_enables(NOT_ALWAYS_ON_ITEMS) = {'off'}; 
  for i=1:length(NOT_ALWAYS_ON_ITEMS)
      if NOT_ALWAYS_ON_ITEMSstatus(i),
          mask_visibles{NOT_ALWAYS_ON_ITEMS(i)}  = 'on';  mask_enables{NOT_ALWAYS_ON_ITEMS(i)}   = 'on';
      end
  end    

  %---------------------------------------------------------------------------
  % STEP-5:
  if (~isequal(mask_visibles, old_mask_visibles))
      set_param(blkh, 'MaskVisibilities', mask_visibles);
  end
  if (~isequal(mask_enables, old_mask_enables))
      set_param(blkh, 'MaskEnables', mask_enables);
  end

end % end of switch statement

% [EOF] dspblksqenc.m

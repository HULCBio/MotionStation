function [si,so,disp_str] = dspblksq(action)
% DSPBLKSQ Signal Processing Blockset Scalar quantization block helper function.
% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:07:18 $
%  

if nargin==0, action = 'dynamic'; end

blk = gcb;

switch action
case 'icon'
  puQmode = get_param(blk,'Qmode');
  paramsrc = get_param(blk, 'QparamSource');
  outerr = get_param(blk,'outQError');
  i = 1;
  j = 1;
  si(i).port = 1;
  si(i).txt = 'U';
  if strcmp(puQmode, 'Encoder'),  
    disp_str='Encoder';
    if strcmp(paramsrc, 'Input ports'),   
        si(i).port = 1;
        si(i).txt = 'U';
        i = i+1;
        si(i).port = 2;
        si(i).txt = 'B';
    end        
    so(j).port = 1;
    so(j).txt = 'Idx';
elseif strcmp(puQmode, 'Decoder'),
    si(i).txt = 'Idx';
    disp_str='Decoder';
    if strcmp(paramsrc, 'Input ports'),   
        si(i).port = 1;
        si(i).txt = 'Idx';
        i = i + 1;
        si(i).port = 2;
        si(i).txt = 'C';
    end
    so(j).port = 1;
    so(j).txt = 'Q(U)';
else 
    disp_str='Encoder\n & \nDecoder';
    if strcmp(paramsrc, 'Input ports'),   
        si(i).port = 1;
        si(i).txt = 'U';
        i = i + 1;
        si(i).port = 2;
        si(i).txt = 'B';
        i = i + 1;
        si(i).port = 3;
        si(i).txt = 'C';
    end
    so(j).port = 1;
    so(j).txt = 'Idx';
    j = j + 1;
    so(j).port = 2;
    so(j).txt = 'Q(U)';
    if strcmp(outerr, 'on'),   
        j = j + 1;
        so(j).port = 3;
        so(j).txt = 'Err';
    end
end

for m=i+1:3, si(m)=si(i); end
for n=j+1:3, so(n)=so(j); end
 
case 'dynamic'
  % Execute dynamic dialogs
  mask_visibles     = get_param(blk, 'MaskVisibilities');
  old_mask_visibles = mask_visibles;
  mask_enables      = get_param(blk, 'MaskEnables');
  old_mask_enables  = mask_enables;
  % mask_visibles{1}  -> Quanitzer mode
  % mask_visibles{2}  -> Source of quantization parameters
  % mask_visibles{3}  -> Quantization partitions
  % mask_visibles{4}  -> Quantization codebook
  % mask_visibles{5}  -> Searching method
  % mask_visibles{6}  -> tie-breaking rule
  % mask_visibles{7}  -> Output the quantization error
  
  % mask_visibles{8}  -> Action to be taken in case of invalid input index
  
  % mask_visibles{9}  -> Need additional parameters (for setting data type)?
  % mask_visibles{10}  -> Index data type pop-up (for encoder and both mode)
  % mask_visibles{11} -> Code word data type pop-up (for decoder mode)
  mask_visibles{1}  = 'on'; % Quantizer mode visible
  mask_enables{1}   = 'on'; % and always enabled
  mask_visibles{2}  = 'on'; % Source of quantization parameters always visible
  mask_enables{2}   = 'on'; % and always enabled
  mask_visibles{8}  = 'off'; % In case of invalid index input pop-up visible only in decoder mode. 
  mask_enables{8}   = 'off'; % and  enabled only in decoder mode. 
  puQmode = get_param(blk,'Qmode');
  paramsrc = get_param(blk, 'QparamSource');
  add_params = get_param(blk, 'dtype');
  if strcmp(puQmode, 'Encoder'),  
    if strcmp(paramsrc, 'Specify via dialog'),   
        mask_visibles{3}  = 'on';  mask_enables{3}   = 'on'; % Need edit box for quantization partition
    else
        mask_visibles{3}  = 'off';  mask_enables{3}   = 'off'; % Need edit box for quantization partition
    end        
    mask_visibles{4}  = 'off';  mask_enables{4}   = 'off'; % Don't need edit box for quantization codebook
    mask_visibles{5}  = 'on';  mask_enables{5}   = 'on'; % enable searching method parameter
    mask_visibles{6}  = 'on';  mask_enables{6}   = 'on'; % enable tie-breaking rule parameter
    mask_visibles{7}  = 'off';  mask_enables{7}   = 'off'; % don't need quantization error checkbox
    mask_visibles{9}  = 'on';  mask_enables{9}   = 'on'; % enable additional parameter checkbox
    if strcmp(add_params, 'on')
        mask_visibles{10}  = 'on';  mask_enables{10}   = 'on'; % need pop-up for index data type.
    else 
        mask_visibles{10}  = 'off';  mask_enables{10}   = 'off'; % don't need pop-up for index data type.
    end
    mask_visibles{11}  = 'off';  mask_enables{11}   = 'off'; % don't need pop-up for CW data type.
  elseif strcmp(puQmode, 'Decoder'), 
    mask_visibles{3}  = 'off';  mask_enables{3}   = 'off'; % Don't need edit box for quantization partition
    mask_visibles{8}  = 'on';  mask_enables{8}   = 'on'; 
    if strcmp(paramsrc, 'Specify via dialog'),   
        mask_visibles{4}  = 'on';  mask_enables{4}   = 'on'; % Need edit box for quantization codebook
        mask_visibles{9}  = 'on';  mask_enables{9}   = 'on'; % need pop-up for CW data type.
        if strcmp(add_params, 'on')
            mask_visibles{11}  = 'on';  mask_enables{11}   = 'on'; % need pop-up for CW data type.
        else 
            mask_visibles{11}  = 'off';  mask_enables{11}   = 'off'; % need pop-up for CW data type.
        end        
    else
        mask_visibles{4}  = 'off';  mask_enables{4}   = 'off'; % Need edit box for quantization codebook
        mask_visibles{9}  = 'off';  mask_enables{9}   = 'off'; % need pop-up for CW data type.
        mask_visibles{11}  = 'off';  mask_enables{11}   = 'off'; % need pop-up for CW data type.
    end        
    mask_visibles{5}  = 'off';  mask_enables{5}   = 'off'; % enable searching method parameter
    mask_visibles{6}  = 'off';  mask_enables{6}   = 'off'; % enable tie-breaking rule parameter
    mask_visibles{7}  = 'off';  mask_enables{7}   = 'off'; % don't need quantization error checkbox
    mask_visibles{10}  = 'off';  mask_enables{10}   = 'off'; % don't need pop-up for index data type.
 else
    mask_visibles{3}  = 'off';  mask_enables{3}   = 'off'; % Don't need edit box for quantization partition
    if strcmp(paramsrc, 'Specify via dialog'),   
        mask_visibles{3}  = 'on';  mask_enables{3}   = 'on'; % Don't need edit box for quantization partition
        mask_visibles{4}  = 'on';  mask_enables{4}   = 'on'; % Need edit box for quantization codebook
    else
        mask_visibles{3}  = 'off';  mask_enables{3}   = 'off'; % Don't need edit box for quantization partition
        mask_visibles{4}  = 'off';  mask_enables{4}   = 'off'; % Need edit box for quantization codebook
    end        
    mask_visibles{5}  = 'on';  mask_enables{5}   = 'on'; % enable searching method parameter
    mask_visibles{6}  = 'on';  mask_enables{6}   = 'on'; % enable tie-breaking rule parameter
    mask_visibles{7}  = 'on';  mask_enables{7}   = 'on'; % need quantization error checkbox
    mask_visibles{9}  = 'on';  mask_enables{9}   = 'on'; % enable additional parameter checkbox
    if strcmp(add_params, 'on')
        mask_visibles{10}  = 'on';  mask_enables{10}   = 'on'; % need pop-up for index data type.
    else
        mask_visibles{10}  = 'off';  mask_enables{10}   = 'off'; % need pop-up for index data type.
    end        
    mask_visibles{11}  = 'off';  mask_enables{11}   = 'off'; % don't need pop-up for CW data type.
 end
  if (~isequal(mask_visibles, old_mask_visibles))
      set_param(blk, 'MaskVisibilities', mask_visibles);
  end
  if (~isequal(mask_enables, old_mask_enables))
      set_param(blk, 'MaskEnables', mask_enables);
  end

end % end of switch statement

% [EOF] dspblksq.m

function prm_disp_cntrl(block)

prm_to_disp=str2num(strrep(get_param(block,'prm_to_disp'), '.', ' '))+3;

mask_visibilities=get_param(block,'MaskVisibilities');
mask_visibilities(4:end)={'off'};
mask_visibilities(prm_to_disp(1):prm_to_disp(2))={'on'};
set_param(block,'MaskVisibilities',mask_visibilities);



% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:24:45 $

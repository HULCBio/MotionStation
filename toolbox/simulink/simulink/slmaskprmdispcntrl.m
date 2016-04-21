function slmaskprmdispcntrl(block)  
%SLMASKPRMDISPCNTRL Simulink Mask Parameters Display Control is a callback
%   function used by RTW generated S-function masks to control the subset
%   of a large parameter set shown in the mask.
%  
   
%   Copyright 1990-2002 The MathWorks, Inc.
%%
%% Notice that the 'prm_to_disp' option name is hard coded in
%% rtw_c.m, ssgensfunpost.m and this file. If the option name
%% gets changed, it has to be changed in those files accordingly.
%%
  maskVariables = get_param(block,'MaskVariables');
  [s,e,t] = regexp(maskVariables,'prm_to_disp=@(\d)');
  startIndex = str2num(maskVariables(t{1}(1):t{1}(2)));
  
  prm_to_disp = str2num(strrep(get_param(block,'prm_to_disp'), '.', ' '));
  prm_to_disp = prm_to_disp + startIndex;
  
  mask_visibilities=get_param(block,'MaskVisibilities');
  mask_visibilities(startIndex+1:end)={'off'};
  mask_visibilities(prm_to_disp(1):prm_to_disp(2))={'on'};
  set_param(block,'MaskVisibilities',mask_visibilities);



%   $Revision: 1.1.4.1 $  $Date: 2002/10/26 16:50:32 $

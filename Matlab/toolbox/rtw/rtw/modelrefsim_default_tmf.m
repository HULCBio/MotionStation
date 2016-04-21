function [tmf,envVal] = modelrefsim_default_tmf
% MODELREFSIM_DEFAULT_TMF Returns the "default" template makefile for use with modelrefsim.tlc
%
% See get_tmf_for_target in the toolbox/rtw/private directory for more 
% information.

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/15 00:23:27 $

  [tmf,envVal] = get_tmf_for_target('modelrefsim');
  if ~isunix 
    if ~strcmp(tmf,'modelrefsim_vc.tmf')
      tmf = 'modelrefsim_lcc.tmf';
      envVal = '';
    end    
  end
  
  
%end modelrefsim_default_tmf.m

function value = rtw_prodhw_get(model,name,component)
% RTW_PRODHW_GET - gets the specified property for the
% production hardware that a Simulink model will be deployed on.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
  
  if nargin < 3
    component = 'Hardware Implementation';
  end
  
  cs = getActiveConfigSet(model);
  hardware = cs.getComponent(component);

  value = get_param(hardware,name);

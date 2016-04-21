function setActiveConfigSet(mdl, name)
% Set a configuration set to be the active configuration set

% Copyright 2002 The MathWorks, Inc.
  
  hMdl = get_param(mdl, 'Object');
  hMdl.setActiveConfigSet(name);
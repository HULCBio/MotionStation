function h = getActiveConfigSet(mdl)
% Get the active configuration set from a model

% Copyright 2002 The MathWorks, Inc.
  
  hMdl = get_param(mdl, 'Object');
 
  h = getActiveConfigSet(hMdl);
  
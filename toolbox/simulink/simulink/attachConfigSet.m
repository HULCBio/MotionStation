function attachConfigSet(mdl, h)
% Attach a configuration set to a model

% Copyright 2002 The MathWorks, Inc.
  
  hMdl = get_param(mdl, 'Object');
  hMdl.attachConfigSet(h);
  

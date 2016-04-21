function h = getConfigSet(mdl, name)
% Get a configuration set from a model

% Copyright 2002 The MathWorks, Inc.

  hMdl = get_param(mdl, 'Object');
  h = hMdl.getConfigSet(name);
  
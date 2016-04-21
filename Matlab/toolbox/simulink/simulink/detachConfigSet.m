function h = detachConfigSet(mdl, name)
% Detach a configuration set from a model

% Copyright 2002 The MathWorks, Inc.

  hMdl = get_param(mdl, 'Object');
  h = hMdl.detachConfigSet(name);

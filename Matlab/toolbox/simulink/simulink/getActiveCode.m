function h = getActiveCode(mdl)
% Get the active code object from a model

% Copyright 2003 The MathWorks, Inc.
  
  hMdl = get_param(mdl, 'Object');
 
  h = getActiveCodeObj(hMdl);
  
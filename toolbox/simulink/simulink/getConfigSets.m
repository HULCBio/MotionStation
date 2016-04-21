function ret = getConfigSets(mdl)
%GETCONFIGSETS: Get the names of all configuration sets that are attached to
% a model

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  hMdl = get_param(mdl, 'Object');
  ret = hMdl.getConfigSets;
  
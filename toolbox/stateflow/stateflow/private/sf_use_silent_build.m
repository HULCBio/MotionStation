function result = sf_use_silent_build

%SF_USE_SILENT_BUILD
% return whether or not Stateflow builds silently.

%   Yao Ren
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:59:53 $

result = sf('Feature','SilentBuilds') & ~testing_stateflow_in_bat;
return;

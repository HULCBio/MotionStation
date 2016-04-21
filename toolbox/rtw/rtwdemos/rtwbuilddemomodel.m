function rtwbuilddemomodel(model)
%RTWBUILDDEMOMODEL  Call Real-Time Workshop to build code for demo models.
% 

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/15 00:26:04 $

try
  rtwbuild(model);
catch
  error(lasterr);
end

set_param(model,'dirty','off');

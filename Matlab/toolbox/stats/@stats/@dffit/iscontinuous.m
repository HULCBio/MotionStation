function result = iscontinuous(hFit)
%ISCONTINUOUS Is this distribution continuous?

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:49 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Smooth fits are always continuous
if isequal(hFit.fittype, 'smooth')
   result = true;
else
   result = hFit.distspec.iscontinuous;
end

function resp = getprop(obj,propname)
% Private. Set the private property to a certain value.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:10:39 $

error(nargchk(2,2,nargin));
if ~ischar(propname),
    error('Propery name must be a string ');
end
resp = get(obj,propname);

% [EOF] setprop.m
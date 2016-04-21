function setprop(obj,propname,propvalue)
% Private. Set the private property to a certain value.
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:09:29 $

error(nargchk(3,3,nargin));
if ~ischar(propname),
    error('Propery name must be a string ');
end
set(obj,propname,propvalue);

% [EOF] setprop.m
function enabdynprop(h,propname,enabstate)
%ENABDYNPROP Enable/disable dynamic properties.
%   ENABDYNPROP(H, PROP, ENAB) Set the enable state of the dynamic property
%   PROP in the object H to ENAB.
%
%   We enable/disable the set/get accessflags of dynamic properties
%   in order to enable/disable the properties.
    
%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:31:36 $

p = findprop(h,propname);

% Check if the property found was due to partial match
if ~strcmpi(propname,get(p,'Name')),
    error('Property not found.');
end
p.AccessFlags.PublicGet = enabstate;
p.AccessFlags.PublicSet = enabstate;

% [EOF]

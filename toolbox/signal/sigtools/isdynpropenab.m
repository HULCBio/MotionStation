function flag = isdynpropenab(h,propname)
%ISDYNPROPENAB True if dynamic property is enabled (set/get are on).
%   ISDYNPROPENAB(H, PROP) True if the dynamic property PROP in the object
%   H is enabled, i.e. PublicGet and PublicSet are on.
    
%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:31:59 $

p = findprop(h,propname);

% Check if the property found was due to partial match
if ~strcmpi(propname,get(p,'Name')),
    error('Property not found.');
end

flag = strcmpi(p.AccessFlags.PublicGet,'on') && ...
        strcmpi(p.AccessFlags.PublicSet,'on');

% [EOF]

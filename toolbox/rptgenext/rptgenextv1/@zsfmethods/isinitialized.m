function tf=isinitialized(z)
%ISINITIALIZED tells whether or not the object has been formally initialized

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:20 $

d=rgstoredata(z);
if ~isempty(d) & isfield(d,'initialized')
    tf=d.initialized;
else
    tf=logical(0);
end

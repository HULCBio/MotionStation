function tf=isinitialized(z)
%ISINITIALIZED tells whether or not initialize(zslmethods) has been called

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:38 $

d = rgstoredata(z);
if ~isempty(d) & isfield(d,'Initialized')
    tf=d.Initialized;
else
    tf=logical(0);
end
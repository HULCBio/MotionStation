function x = isvalid(n)
%ISVALID True for a valid VRNODE object.
%   X = ISVALID(N) returns an array that contains 1's where the elements
%   of N are valid VRNODE objects and 0's where they are not.
%
%   For a VRNODE object to be valid, the following conditions must be met:
%   the parent world of the associated node must exist, it must be open
%   and the associated node itself must exist.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.9.2.1 $ $Date: 2002/11/17 14:13:47 $ $Author: batserve $


x = false(size(n));
for i = 1:numel(n)
    x(i) = isopen(n(i).World) && vrsfunc('VRT3NodeExists', getparentid(n(i)), n(i).Name);
end

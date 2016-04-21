function x = isvalid(w)
%ISVALID True for a valid VRWORLD object.
%   ISVALID(W) returns an array that contains 1's where the elements
%   of W are valid VRWORLD objects and 0's where they are not.
%   A VRWORLD object is considered valid if its associated world exists.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.8.2.1 $ $Date: 2002/11/17 14:14:13 $ $Author: batserve $

x = false(size(w));
for i = 1:numel(w)
  x(i) = vrsfunc('VRT3SceneValid', w(i).id);
end

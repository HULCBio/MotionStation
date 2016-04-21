function x = isvalid(f)
%ISVALID True for valid VRFIGURE objects.
%   X = ISVALID(F) returns a logical array that contains a 0
%   where the elements of F are invalid VRFIGURE handles
%   and 1 where the elements of F are valid VRFIGURE handles.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.2.3 $ $Date: 2003/07/11 16:01:49 $ $Author: batserve $

vf = vrsfunc('GetAllFigures');
x = false(size(f));
for i=1:numel(f)
  x(i) = any(f(i).handle==vf);
end

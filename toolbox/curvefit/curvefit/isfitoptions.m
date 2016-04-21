function flag = isfitoptions(obj)
% ISFITOPTIONS True for fitoptions object.
%   ISFITOPTIONS(OBJ) returns 1 if OBJ is a fitoptions object and 0 otherwise.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:42:06 $

flag = logical(0);
if isa(obj, 'curvefit.basefitoptions')
    flag = logical(1);
end
function I = isequal(e1,e2)
%ISEQUAL Comparison of event vectors
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:14 $

if length(e1) == length(e2)
    for k=length(e1):-1:1
        I(k) = localCompare(e1(k),e2(k));
    end
elseif isscalar(e2)
    for k=length(e1):-1:1
        I(k) = localCompare(e1(k),e2);
    end
elseif isscalar(e1)
    for k=length(e2):-1:1
        I(k) = localCompare(e1,e2(k));
    end
else
    error('Inputs must be the same size or either one can be a scalar.')
end


function result = localCompare(e1,e2)

if isequal(e1.EventData,e2.EventData) && strcmp(e1.Name,e2.Name) && ...
                isequal(e1.Parent,e2.Parent) && isequal(e1.Time,e2.Time)
    result = true;
else
    result = false;
end
        
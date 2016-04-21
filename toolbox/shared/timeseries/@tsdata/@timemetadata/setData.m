function out = setData(h, newval)
%SETDATA Assigns data to the time ValueArray storage object
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:42 $

% update the @timemetadata to reflect the new  data
h.reset(newval);

if isfinite(h.increment)
    out = [];
else
    out = newval;
end    

function L = getlength(h)
%GETLENGTH Access method for the private length property
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:03 $

% Access method to get time series length
error('abstracttimemetadata:getlength:overload',...
    'getlength must be overloaded for abstracttimemetadata derived classes')

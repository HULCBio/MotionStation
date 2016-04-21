function setlength(h,L)
%SETLENGTH Access method for the private length property
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:05 $

% Access method to set time series length
error('abstracttimemetadata:setlength:overload',...
    'setlength must be overloaded for abstracttimemetadata derived classes')

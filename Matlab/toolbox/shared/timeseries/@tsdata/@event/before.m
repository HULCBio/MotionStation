function I = before(e)
%BEFORE Identifies the samples that occur before the specfied event
%
%   See also AFTER.
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:09 $

if isempty(e.Parent)
    I = [];
else
    I = find(e.Parent.Time<e.Time);
end

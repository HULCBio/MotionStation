function I = between(e1,e2)
%BETWEEN Identifies the samples that occur between the specfied events
%
%   See also BEFORE, AFTER.
%
%   Authors: James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:33:10 $

if ~isequal(e1.Parent,e2.Parent)
    error('event:between:noblended',...
        'Events must have the same parent timeseries object')
end
if isempty(e1.Parent) || isempty(e2.Parent)
    I = [];
else
    I = find(e1.Parent.Time>=e1.Time & e2.Parent.Time<=e2.Time);
end

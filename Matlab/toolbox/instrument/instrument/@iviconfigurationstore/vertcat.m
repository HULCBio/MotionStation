function out = vertcat(varargin)
%VERTCAT Vertical concatenation of IVI Configuration Store objects.
%

%   MP 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:26 $

% Concatenate objects.
try
    out = builtin('vertcat', varargin{:});
catch
    rethrow(lasterror);
end

% Error if a matrix of objects was created.
if (length(out) ~= numel(out))
    error('iviconfigurationstore:vertcat:nonMatrixConcat', 'Only a row or column vector of IVI Configuration Store objects can be created.')
end
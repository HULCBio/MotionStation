function varargout = padlength(varargin)
%PADLENGTH Pad input vectors with ones to give them equal lengths.
%
%   Example
%   -------
%       [a,b,c] = padlength([1 2],[1 2 3 4],[1 2 3 4 5])
%       a = 1 2 1 1 1
%       b = 1 2 3 4 1
%       c = 1 2 3 4 5

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.7.4.2 $  $Date: 2003/08/23 05:54:22 $

% Find longest size vector.  Call its length "numDims".
numDims = zeros(nargin, 1);
for k = 1:nargin
    numDims(k) = length(varargin{k});
end
numDims = max(numDims);

% Append ones to input vectors so that they all have the same length;
% assign the results to the output arguments.
limit = max(1,nargout);
varargout = cell(1,limit);
for k = 1 : limit
    varargout{k} = [varargin{k} ones(1,numDims-length(varargin{k}))];
end

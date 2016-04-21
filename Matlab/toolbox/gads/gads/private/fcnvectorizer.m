function y = fcnvectorizer(pop,varargin)
%FCNVECTORIZER is a utility function used for scalar fitness functions.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2004/01/16 16:50:32 $


if nargin < 2  
    error('gads:FCNVECTORIZER:numberOfInputs','FCNVECTORIZER requires at least 2 inputs');
end

temp = feval(varargin{1},pop(1,:),varargin{2:end});
if length(temp) ==1 && ~isobject(temp)
    y    = repmat(temp,size(pop,1),1);
    for i = 2:size(pop,1)
        y(i) = feval(varargin{1},pop(i,:),varargin{2:end});
    end
else %This custom type must be a vectorized call
    y = feval(varargin{1},pop,varargin{2:end});
end

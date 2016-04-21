function [result,pvpairs] = vectorizepvpairs(pvpairs,n,keys)
%VECTORIZEPVPAIRS Vectorize property-value pairs
%   [RES,NEWPAIRS] = VECTORIZEPVPAIRS(PVPAIRS,N,KEYS) finds any
%   properties in the property-value list PVPAIRS that match a
%   property name in the cell array KEYS and "vectorizes" the property
%   value to be a legal MATLAB indexing expression indexing the
%   columns or calls to GETCOLUMN. The vectorized strings are returned
%   in RES as a 2 dimensional cell array where each column is the
%   pvpair list for the corresponding column expression.
%   NEWPAIRS is the list PVPAIRS with the vectorized entries
%   removed.  The vectorized strings have the form
%   'x(:,1)','x(:,2)' etc. or 'getcolumn(expr,1)', 'getcolumn(expr,2)' etc.
%
%   See also GETCOLUMN

%   Copyright 1984-2003 The MathWorks, Inc. 

result = cell(n,0);
for k=1:length(keys)
  key = keys{k};
  ind = find(strcmpi(pvpairs,key));
  if ~isempty(ind)
    ind = unique([ind ind+1]);
    varname = pvpairs{ind(end)};
    pvpairs(ind) = [];
    result(:,end+1) = {key};
    result(:,end+1) = getcolumn(varname,1:n,'expression');
  end
end

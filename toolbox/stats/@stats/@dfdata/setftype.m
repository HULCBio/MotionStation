function setftype(ds,ftype)
%SETFTYPE Set function type for plotting of data set

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:37 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Must have two inputs of proper type
if nargin<2 || ~ischar(ftype)
   error('stats:dfdata:setftype:BadFunctionType',...
         'Must supply a valid function type');
end

% Verify input value
oktypes = {'cdf' 'icdf' 'pdf' 'probplot' 'survivor' 'cumhazard'};
j = strmatch(ftype,oktypes);
if isempty(j)
   error('stats:dfdata:setftype:BadFunctionType','Invalid function type.')
elseif length(j)>1
   error('stats:dfdata:setftype:BadFunctionType','Ambiguous function type.');
end
ftype = oktypes{j};

% If changing type, clear out information no longer correct
oldtype = ds.ftype;
if ~isequal(oldtype,ftype)
   clearplot(ds);
end

% Now we can set the new value
ds.ftype = ftype;
function setftype(hFit,ftype)
%SETFTYPE Method to set function type for plotting of fit

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:52 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Must have two inputs of proper type
if nargin<2 || ~ischar(ftype)
   error('stats:dffit:setftype:BadFunctionType',...
         'Must supply a valid function type');
end

% Verify input value
oktypes = {'cdf' 'icdf' 'pdf' 'probplot' 'survivor' 'cumhazard'};
j = strmatch(ftype,oktypes);
if isempty(j)
   error('stats:dffit:setftype:BadFunctionType','Invalid function type.')
elseif length(j)>1
   error('stats:dffit:setftype:BadFunctionType','Ambiguous function type.');
end
ftype = oktypes{j};

% If changing type, clear out information no longer correct
oldtype = hFit.ftype;
if ~isequal(oldtype,ftype)
   clearplot(hFit);
end

% Now we can set the new value
hFit.ftype = ftype;

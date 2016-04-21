function markAsParameter(hThis,propnames)
% Tells code object to mark property as parameter

% Copyright 2003 The MathWorks, Inc.

% Cast to cell array of string if just a string
if isstr(propnames)
  propnames = {propnames};
end

% Only cell array of strings valid input
if ~iscellstr(propnames)
  error('MATLAB:codetools:codegen',...
        'Invalid input, requires cell array of strings');
end

% Get handles
hMomento = get(hThis,'MomentoRef');

% Loop through all properties and mark them as parameters.
hPropList = get(hMomento,'PropertyObjects');
for n = 1:length(hPropList)
    hProp = hPropList(n);
    name = get(hProp,'Name');
    if any(strcmpi(name,propnames))
       set(hProp,'IsParameter',true);  
    end
end


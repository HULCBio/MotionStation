function [bool] = hasProperty(hThis,propname)
% Return true is recorded by code object

% Copyright 2003 The MathWorks, Inc.

bool = false;

% Only take strings
if ~isstr(propname)
    error('MATLAB:codetools:codegen',...
        'Invalid input, string required');
end

% Get handles
hMomento = get(hThis,'MomentoRef');

% Loop through all properties and mark them to be ignored.
hPropList = get(hMomento,'PropertyObjects');
for n = 1:length(hPropList)
    hProp = hPropList(n);
    doignore = get(hProp,'Ignore');
    name = get(hProp,'Name');
    if ~doignore && strcmp(name,propname)  
       bool = true;
       break;
    end
end


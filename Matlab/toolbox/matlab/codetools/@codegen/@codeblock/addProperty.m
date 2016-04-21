function addProperty(hThis,propname)
% Tells code object add property

% Copyright 2004 The MathWorks, Inc.

% Only cell array of strings valid input
if ~isstr(propname)
  error('MATLAB:codetools:codegen',...
        'Invalid input, requires string');
end

% Get handles
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
if ~ishandle(hObj)
    error('MATLAB:codetools:codegen','Invalid state');
    return;
end
hObj = handle(hObj);

% Get property object
hProp = findprop(hObj,propname);
if isempty(hProp)
    error('MATLAB:codetools:codegen',['Invalid property ' propname]);
    return; 
end

% Get list of properties
hPropList = get(hMomento,'PropertyObjects');

% Store property info
pobj = codegen.momentoproperty;
set(pobj,'Name',propname);
set(pobj,'Value',get(hObj,propname));
set(pobj,'Object',hProp);

% Update list
set(hMomento,'PropertyObjects',[hPropList,pobj]);



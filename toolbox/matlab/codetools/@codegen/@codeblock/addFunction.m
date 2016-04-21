function addFunction(hThis,hFunc)
% Add function object to code object's function list

% Copyright 2003 The MathWorks, Inc.

hFuncList = get(hThis,'FunctionObjects');
hFuncList = [hFunc,hFuncList];
set(hThis,'FunctionObjects',hFuncList);

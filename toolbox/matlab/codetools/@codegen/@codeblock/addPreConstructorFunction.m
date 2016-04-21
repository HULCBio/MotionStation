function addPreConstructorFunction(hThis,hFunc)

% Copyright 2003 The MathWorks, Inc.

hFuncList = get(hThis,'PreConstructorFunctions');
hFuncList = [hFunc,hFuncList];
set(hThis,'PreConstructorFunctions',hFuncList);

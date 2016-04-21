function addPostConstructorFunction(hThis,hFunc)

% Copyright 2003 The MathWorks, Inc.

hFuncList = get(hThis,'PostConstructorFunctions');
hFuncList = [hFunc,hFuncList];
set(hThis,'PostConstructorFunctions',hFuncList);

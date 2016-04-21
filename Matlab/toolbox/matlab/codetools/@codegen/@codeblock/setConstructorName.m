function setConstructorName(hThis,name)

% Copyright 2003 The MathWorks, Inc.

hFunc = getConstructor(hThis);
set(hFunc,'Name',name);
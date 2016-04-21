function updateDataCursor(this,hDataCursor,target)

% Copyright 2003 The MathWorks, Inc.

ch = get(this,'children');
updateDataCursor(hDataCursor,handle(ch(1)),hDataCursor,target);
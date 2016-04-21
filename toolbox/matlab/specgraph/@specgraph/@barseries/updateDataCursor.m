function updateDataCursor(this,hDataCursor,target)

% Copyright 2003 The MathWorks, Inc.

ch = get(this,'children');
updateDataCursor(hDataCursor,handle(ch),hDataCursor,target);
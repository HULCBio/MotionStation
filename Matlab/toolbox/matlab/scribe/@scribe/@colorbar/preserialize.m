function olddata = preserialize(this)
%PRESERIALIZE Prepare object for serialization

% Copyright 2003 The MathWorks, Inc.

olddata = [];

% remove data containing function handles that won't load
delete(get(this,'UIContextMenu'));

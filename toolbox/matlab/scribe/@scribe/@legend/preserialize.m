function olddata = preserialize(this)
%PRESERIALIZE Prepare object for serialization

%   Copyright 1984-2004 The MathWorks, Inc.

olddata = [];

% remove data containing function handles that won't load
delete(get(this,'UIContextMenu'));
set(this,'ButtonDownFcn','');
set(this.ItemText,'ButtonDownFcn','');
setappdata(double(this),'PlotChildren',double(this.PlotChildren));
setappdata(double(this),'PeerAxes',double(this.Axes));

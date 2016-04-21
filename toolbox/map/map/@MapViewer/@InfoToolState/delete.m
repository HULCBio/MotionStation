function delete(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:49:33 $

activeLayerHandles = this.Viewer.Axis.getLayerHandles(this.Viewer.ActiveLayerName);
set(activeLayerHandles,'ButtonDownFcn','');

this.Viewer.PreviousInfoToolState = this;
this= [];
%delete(this);

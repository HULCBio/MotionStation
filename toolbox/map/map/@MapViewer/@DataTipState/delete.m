function delete(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:29 $

activeLayerHandles = this.Viewer.Axis.getLayerHandles(this.ActiveLayerName);
set(activeLayerHandles,'ButtonDownFcn','');

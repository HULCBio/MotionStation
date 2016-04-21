function addLayer(this,layer)
%ADDLAYER Add a layer to the viewer
%
%   ADDLAYER(LAYER) adds the MapModel.layer object to the MapView.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:50 $

scribefiglisten(this.Figure,'off');
this.Map.addLayer(layer);
scribefiglisten(this.Figure,'on');

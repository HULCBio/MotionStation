function setLayerLegend(this,layername,legend)
%SETLAYERLEGEND Sets a legend for a specific layer
%
%   SETLAYERLEGEND(LAYERNAME,LEGEND) Sets LAYERNAME's legend to the
%   mapmodel.legend LEGEND.  A LayerChanged event is broadcast.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:10 $

layer = this.getLayer(layername);
layer.setLegend(legend);

% Generate and broadcast an event that a layer has been removed.
EventData = LayerEvent.LegendChanged(this,layer);
this.send('LegendChanged',EventData);

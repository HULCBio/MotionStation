function setLayerOrder(this,layerorder)
%SETLAYERORDER Set order of layers in model
%
%   SETLAYERORDER(LAYERORDER) sets the order of the layers to the names of the
%   layers in the cell array of strings, LAYERORDER.  The first element of
%   LAYERORDER is the top most layer. The desired layer order must be a
%   permutation of the current layer order.  A LayerOrderChanged event is
%   broadcast.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:34 $

currentlayerorder = getLayerOrder(this);
if ~isequal(sort(layerorder(:)),sort(currentlayerorder(:)))
  error(['The desired layer order must be a permutation of the current layer '...
         'order.']);
end

% Make it a column vector
this.Configuration = layerorder(:);

% Create and broadcast an event that the layer order has changed.
EventData = LayerEvent.LayerOrderChanged(this,layerorder);
this.send('LayerOrderChanged',EventData);

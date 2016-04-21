function h = LayerOrderChanged(hSrc,layerorder)
%LAYERORDERCHAGNED Subclass of EventData to handle changing the layer order.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:12 $

h = LayerEvent.LayerOrderChanged(hSrc,'LayerOrderChanged');
h.layerorder = layerorder;

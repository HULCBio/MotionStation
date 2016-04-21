function h = LayerRemoved(hSrc,layername)
%LAYERREMOVED Subclass of EventData to handle removing a layer from the model

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:14 $

h = LayerEvent.LayerRemoved(hSrc,'LayerRemoved');
h.LayerName = layername;

function removeLayer(this,layerName)
%REMOVELAYER Remove layer from viewer
%
%   removeLayer(LAYERNAME) removes the layer with the name LAYERNAME from the
%   view.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:04 $

this.Map.removeLayer(layerName);


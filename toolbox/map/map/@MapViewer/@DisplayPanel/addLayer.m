function addLayer(this,layer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:29 $

layername = layer.getLayerName;
newUIString = [get(this.ActiveLayerDisplay,'String');{layername}];
set(this.ActiveLayerDisplay,'String',newUIString);
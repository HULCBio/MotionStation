function setActiveLayer(this,layerName)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:31 $

idx = strmatch(layerName,get(this.ActiveLayerDisplay,'String'),'exact');
set(this.ActiveLayerDisplay,'Value',idx);

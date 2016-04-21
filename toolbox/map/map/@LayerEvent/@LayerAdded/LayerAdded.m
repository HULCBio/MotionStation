function h = LayerAdded(hSrc,layername)
%LAYERADDED Subclass of EventData to handle adding a layer to the model

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:10 $

h = LayerEvent.LayerAdded(hSrc,'LayerAdded');
h.LayerName = layername;


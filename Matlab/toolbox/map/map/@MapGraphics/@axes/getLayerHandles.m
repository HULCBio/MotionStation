function h = getLayerHandles(this,LayerName)
%GETLAYERHANDLES Get all graphics handles for a layer

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:54 $

% Change the double handle into a handle object
children = handle(get(this,'Children'));

% Each layer has a unique name.  All handles for a layer will be grouped
% together.
h = children(strmatch(LayerName,[get(children,'LayerName')],'exact'));
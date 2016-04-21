function h = LegendChanged(hSrc,layer)
%LEGENDCHANGED Constructor for LEGENDCHANGED

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:16 $

h = LayerEvent.LegendChanged(hSrc,'LegendChanged');
h.layer = layer;

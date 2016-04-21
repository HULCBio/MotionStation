function h = LineLayer(name)
%LINELAYER Constructor for the line layer class
%
%   LINELAYER(NAME) creates a vector layer with the name NAME for line
%   features. The object will be constructed with a default legend.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:20 $

h = MapModel.LineLayer;

h.componentType = 'LineComponent';
h.layername = name;
h.legend = MapModel.LineLegend;
h.visible = 'on';
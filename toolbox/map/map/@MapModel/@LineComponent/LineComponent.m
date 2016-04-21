function h = LineComponent(attributeNames)
%LINECOMPONENT Constructor for a component of a line layer.
%
%   LINECOMPONENT constructs a LineComponent object

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:17 $

h = MapModel.LineComponent;

h.AttributeNames = attributeNames;

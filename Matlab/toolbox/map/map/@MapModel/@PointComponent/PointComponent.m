function h = PointComponent(attributeNames)
%POINTCOMPONENT Constructor for a component of a point layer.
%
%   POINTCOMPONENT constructs a PointComponent object

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:37 $

h = MapModel.PointComponent;

h.AttributeNames = attributeNames;
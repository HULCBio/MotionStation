function aColor = getColor(this)
%GETCOLOR Returns the color for the VectorLegend.
%
%   GETCOLOR cycles through the ColorTable and returns the colors in order.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:20 $

aColor = rand(1,3)/2 + 0.25;

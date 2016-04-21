function [FigWidth,FigHeight] = figsize(h,Units)
%FIGSIZE  Computes figure width and height in the requested units.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:18 $

% RE: Do not get/set Position here (triggers resize listeners)
Fig = fighndl(h);
CurrentUnits = get(Fig,'Units');

% Get position in specified units
set(Fig,'Units',Units);
FigPos = get(Fig,'Position');
FigWidth = FigPos(3);
FigHeight = FigPos(4);

% Restore original units/position
set(Fig,'Units',CurrentUnits)
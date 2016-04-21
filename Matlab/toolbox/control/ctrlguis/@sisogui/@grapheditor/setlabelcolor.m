function setlabelcolor(Editor,varargin)
%SETLABELCOLOR  Updates the color of the axes labels, rulers, and grid.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:02:12 $

Axes = Editor.Axes;
Color = Editor.LabelColor;

% Axes color
Axes.AxesStyle.XColor = Color;
Axes.AxesStyle.YColor = Color;

% Axes labels
Axes.TitleStyle.Color = Color;
Axes.XLabelStyle.Color = Color;
Axes.YLabelStyle.Color = Color;
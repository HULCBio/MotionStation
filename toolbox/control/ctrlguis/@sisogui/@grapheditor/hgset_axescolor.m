function hgset_axescolor(Editor,Color)
% HG rendering of AxesForegroundColor property

%   Author(s): P. Gahinet
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2001/08/05 02:00:22 $

% Change color
HG = Editor.HG;

% Axes color
set(Editor.Axes,'RulerColor',Color)

% Grid lines
if isfield(HG,'GridLines')
    set(findobj(HG.GridLines,'Type','line'),'Color',Color)
    set(findobj(HG.GridLines,'Type','text'),'Color',0.5*Color)
end

% Labels
% REVISIT: streamline
Title = Editor.Title;
Title.Color = Color;
Editor.Title = Title;
Xlabel = Editor.Xlabel;
Xlabel.Color = Color;
Editor.Xlabel = Xlabel;
Ylabel = Editor.Ylabel;
Ylabel.Color = Color;
Editor.Ylabel = Ylabel;



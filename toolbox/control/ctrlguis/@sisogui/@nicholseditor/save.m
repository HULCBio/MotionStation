function SavedData = save(Editor)
%SAVE   Creates backup of Nichols Editor settings.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:04:39 $

Axes = Editor.Axes;
PlotAxes = getaxes(Editor.Axes);

SavedData = struct(...
    'Constraints',Editor.saveconstr,...
    'Grid',Axes.Grid,...
    'Title',Axes.Title,...
    'TitleStyle',struct(Axes.TitleStyle),...
    'Visible',Editor.Visible,...
    'XlabelStyle',struct(Axes.XlabelStyle),...
    'Xlabel',{Axes.Xlabel},...
    'Xlim',{get(PlotAxes,'Xlim')},...
    'XlimMode',{Axes.XlimMode},...
    'Ylabel',{Axes.Ylabel},...
    'YlabelStyle',struct(Axes.YlabelStyle),...
    'Ylim',{get(PlotAxes,'Ylim')},...
    'YlimMode',{Axes.YlimMode},...
    'MarginVisible',Editor.MarginVisible);
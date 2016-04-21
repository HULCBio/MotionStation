function hgset_visible(Editor,varargin)
% HG rendering of editor's Visible property.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 05:02:00 $
Axes = Editor.Axes;

% Update @axesgroup vis.
% RE: Disable limit manager to avoid triggering ViewChanged and updatelims
Axes.LimitManager = 'off';
Axes.Visible = Editor.Visible;  
Axes.LimitManager = 'on';

% Clear all selections within axes scope
Axes.EventManager.clearselect(getaxes(Axes,'2d'));

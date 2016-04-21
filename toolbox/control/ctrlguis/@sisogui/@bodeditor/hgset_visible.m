function hgset_visible(Editor,varargin)
% HG rendering of editor's Visible, MagVisible, and PhaseVisible property.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 04:56:26 $
Axes = Editor.Axes;

% Update @axesgroup vis.
% RE: Disable limit manager to avoid triggering ViewChanged and updatelims
Axes.LimitManager = 'off';
Axes.Visible = Editor.Visible;  
Axes.RowVisible = {Editor.MagVisible ; Editor.PhaseVisible};
Axes.LimitManager = 'on';

% Set X/Y label visibility according to internal states (conditioned by layout)
xylabelvis(Editor)

% Clear all selections within axes scope
Axes.EventManager.clearselect(getaxes(Axes,'2d'));


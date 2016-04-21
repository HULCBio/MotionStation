function activate(Editor,varargin)
% Activates editor when data first loaded.

%   $Revision: 1.10 $  $Date: 2002/04/10 05:02:09 $
%   Copyright 1986-2002 The MathWorks, Inc.

% Set all limit modes to auto 
% RE: Initialized to manual so that limits correctly update when 
%     changing units before importing data
% REVISIT: replace line below by commented line
set(Editor.Axes,'XlimMode','auto','YlimMode',repmat({'auto'},[Editor.Axes.Size(1) 1]))
%set(Editor.Axes,'XlimMode','auto','YlimMode','auto')

% Turn editor on
Editor.EditMode = 'idle';

% Enable right-click menu
Editor.setmenu('on');

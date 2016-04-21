function [figtool_manager] = getFigureToolManager(fig)
% Do not use. This utility function will eventually be removed.

% Copyright 2002 The MathWorks, Inc.

%GETFIGURETOOLMANAGER(FIG) gets the figure window's tool manager

KEY = 'graphics_FigureToolManager';

figtool_manager = getappdata(fig,KEY);

% Create a new figure tool manager if one does not already exist
if isempty(figtool_manager) | ~ishandle(figtool_manager)
  figtool_manager = graphics.FigureToolManager(fig);
  setappdata(fig,KEY,figtool_manager);
end

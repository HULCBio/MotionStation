function [retout] = uiundo(hFigure,action,s)
% Internal Use Only

% Copyright 2002 The MathWorks, Inc.

%UIUNDO(FIG,OPTION,C) 
%         FIG is a figure handle
%         ACTION is 'function' | 'add'
%         C is an optional structure containing command information

figtool_manager = localGetFigureToolManager(hFigure);
cmd_manager = figtool_manager.CommandManager;

if strcmp(action,'function')

   % Create command object
   cmd = uiundo.FunctionCommand;
   cmd.Name = s.Name;
   cmd.Function = s.Function;
   cmd.Varargin = s.Varargin;
   cmd.InverseFunction = s.InverseFunction;
   cmd.InverseVarargin = s.InverseVarargin;
   add(cmd_manager,cmd);

elseif strcmp(action,'add')
   add(cmd_manager,s);
end

%------------------------------------------%
function [figtool_manager] = localGetFigureToolManager(fig)

KEY = 'uitools_FigureToolManager';

figtool_manager = getappdata(fig,KEY);

% Create a new figure tool manager if one does not already exist
if isempty(figtool_manager) | ~ishandle(figtool_manager)
  figtool_manager = uitools.FigureToolManager(fig);
  setappdata(fig,KEY,figtool_manager);
end


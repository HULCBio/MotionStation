function zoomout(Editor)
%ZOOMOUT  Manages Zoom Out action.

%   Author(s): P. Gahinet  
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 05:01:30 $

% Host figure
SISOfig = Editor.Axes.Parent;

% Exit zoom mode
% RE: Allow zoom out in add/delete modes without aborting mode
if strcmp(Editor.EditMode,'zoom')
    % Revert to idle (abort global modes)
    Editor.EditMode = 'idle';
end

% Reset limit modes (triggers limit update)
% REVISIT: for max efficiency, push LimitManager='off', set lim mode, pop LimitManager, and call updatelims
Editor.Axes.XlimMode = 'auto';
% REVISIT: replace next line by commented one
Editor.Axes.YlimMode = repmat({'auto'},[Editor.Axes.Size(1) 1]);
%Editor.Axes.YlimMode = 'auto';

% Update status 
Editor.EventManager.newstatus(...
    sprintf('Zoomed out.\nRight-click on plots for more design options.'));
    
   

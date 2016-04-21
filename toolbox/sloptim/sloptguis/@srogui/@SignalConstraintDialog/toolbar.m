function h = toolbar(this)
% Creates the tool bar.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.

IconData = load('sloptimicons');
htoolbar = uitoolbar('Parent',this.Figure,'HandleVisibility','off');
%
% Create menu bar icons and associated callbacks.
%
C = uitoolfactory(htoolbar,'Standard.FileOpen');
set(C,'Tooltip',xlate('Load project'),...
   'ClickedCallback',{@LocalLoadFrom this})
C = uitoolfactory(htoolbar,'Standard.SaveFigure');
set(C,'Tooltip',xlate('Save project'),...
   'ClickedCallback',{@LocalSave this})
C = uitoolfactory(htoolbar,'Standard.PrintFigure');
set(C,'Tooltip',xlate('Print constraint'))

% Zoom and Data Cursor group
C = uitoolfactory(htoolbar,'Exploration.ZoomIn');
set(C,'Separator','on')
uitoolfactory(htoolbar,'Exploration.ZoomOut');
C = handle(uitoolfactory(htoolbar,'Exploration.DataCursor'));
% Enable interaction with lines and disable interaction with constraints 
% in DataCursor mode
C.UserData = handle.listener(C,C.findprop('State'),...
   'PropertyPostSet',@(x,y) setDataTipMode(this.Editor,y.NewValue));

% Start/stop group
Start = uipushtool(htoolbar,...
   'Tooltip',xlate('Start optimization'),...
   'CData',IconData.startbtndata,...
   'ClickedCallback',{@LocalStart this},...
   'Separator','on');
Stop = uipushtool(htoolbar,...
   'Tooltip',xlate('Stop optimization'),...
   'CData',IconData.stopbtndata,...
   'ClickedCallback',{@LocalStop this},...
   'Enable','off');

% Current response
uipushtool(htoolbar,...
   'Tooltip',xlate('Plot current response'),...
   'CData',IconData.plotbtndata,...
   'Tag','initResp',...
   'Separator','on',...
   'ClickedCallback',{@LocalSimCurrent this});

% Set Start/Stop callbacks
OtherButtons = allchild(htoolbar);
OtherButtons(OtherButtons==Stop) = [];
h = struct('Stop',Stop','Other',OtherButtons);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function LocalLoadFrom(eventsrc,eventdata,this)
% Load... menu: open load dialog
loadfrom(this)


function LocalSave(eventsrc,eventdata,this)
% Save menu/button
save(this)


function LocalSimCurrent(eventsrc,eventdata,this)
% Simulate and notify all editors to update
feval(this.Editor.RespFcn{:})


function LocalStart(eventsrc,eventdata,this)
% Start button
optimize(this)


function LocalStop(eventsrc,eventdata,this)
% Stop button
if strcmp(this.RunTimeProject.OptimStatus,'run')
   this.RunTimeProject.OptimStatus = 'stop';
else
   % CTRL-C interrupt (second click)
   this.RunTimeProject.OptimStatus = 'idle';
end



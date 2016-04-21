function this = SisoToolViewer(sisodb)
% Constructor for @SisoToolViewer class.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2002/11/11 22:22:55 $

this = viewgui.SisoToolViewer;
this.Parent = sisodb;

% REVISIT: eliminate when can call parent constructor
initialize(this)
toolbar(this)

% Figure customization
ViewFig = this.Figure;
set(ViewFig,...
   'Name','LTI Viewer for SISO Design Tool',...
   'CloseRequestFcn',{@LocalHide this});

StatusCheckBox = uicontrol('Parent',ViewFig,'Style','checkbox','String','Real-Time Update',...
    'TooltipString','Status Bar','Value',strcmpi('on',this.RealTimeEnable),...
    'Callback',{@LocalRealTime this});
HG = this.HG;
HG.StatusCheckBox = StatusCheckBox;
this.HG = HG;
% Add Listener to Track the SisoToolViewer's RealTimeEnable Property
set(this.HG.StatusCheckBox,'UserData',handle.listener(this,this.findprop('RealTimeEnable'),...
     'PropertyPostSet',{@LocalViewRealTime this.HG.StatusCheckBox}));

% Install CS help
cshelp(ViewFig,sisodb.Figure);

% Customize menus
FigMenus = this.HG.FigureMenu;
set([FigMenus.FileMenu.Import,FigMenus.FileMenu.Export,...
        FigMenus.EditMenu.PlotConfigurations,FigMenus.EditMenu.RefreshSystems,...
        FigMenus.EditMenu.DeleteSystems],'Visible','off')
set(FigMenus.EditMenu.LineStyles,'Separator','off')

% Remove undesirable plot types
availViews = this.AvailableViews;
[junk,ia,ib] = intersect({availViews.Alias},{'bodemag','initial','lsim','iopzmap','sigma'});
availViews(ia) = [];
this.AvailableViews = availViews;

% Install listeners (needed below)
addlisteners(this)

% Install listeners for communication between SISO Tool and Viewer
LoopData = sisodb.LoopData;
L = [handle.listener(LoopData,'ObjectBeingDestroyed',{@LocalClose this});...
      handle.listener(LoopData,'LoopDataChanged',{@LocalUpdate this});...
      handle.listener(LoopData,'MoveGain',{@LocalMoveGain this});...
      handle.listener(LoopData,'MovePZ',{@LocalMovePZ this})];
this.addlisteners(L)

% Initialize contents (create one source per loop transfer)
RespList = resplist(sisodb);  % [Alias/Name/open vs closed]
nresp = size(RespList,1);
ModelData = looptransfers(LoopData,RespList(:,1));
for ct=1:nresp
   src(ct,1) = resppack.ltisource(ModelData{ct},'Name',RespList{ct,2});
end
this.Systems = src;

% Apply pre-defined styles
for ct=1:nresp
   this.setstyle(this.Systems(ct),RespList{ct,4})
end
   

%%%%%%%%%%%%%%%%%
% LocalRealTime %
%%%%%%%%%%%%%%%%%
function LocalRealTime(hSrc,event,this)
% Callback of the check box. Updates the RealTimeEnable property of the
% object.
if get(hSrc,'Value')
    this.RealTimeEnable = 'on';
else
    this.RealTimeEnable = 'off';
end

%%%%%%%%%%%%%%%%%%%%%
% LocalViewRealTime %
%%%%%%%%%%%%%%%%%%%%%
function LocalViewRealTime(hSrc,event,CheckBox)
% Listener Callback of the RealTimeEnable property of the
% object. Will update the CheckBox.
set(CheckBox,'Value',strcmpi('on',event.NewValue));

%%%%%%%%%%%%%%
% LocalClose %
%%%%%%%%%%%%%%
function LocalClose(hSrc,event,this)
% Callback when closing SISO Tool
close(this)

%%%%%%%%%%%%%
% LocalHide %
%%%%%%%%%%%%%
function LocalHide(hSrc,event,this)
% Callback when closing SISO Tool
set(this.Figure,'Visible','off')
this.setCurrentViews(handle([]));

%%%%%%%%%%%%%%%
% LocalUpdate %
%%%%%%%%%%%%%%%
function LocalUpdate(LoopData,event,this)
% Update LTI Viewer.
ActiveViews = getCurrentViews(this);
if strcmp(get(this.Figure,'Visible'),'off') || isempty(ActiveViews)
   return
end
RespList = resplist(this.Parent);

% Disable limit managers to avoid multiple limit updates
AxGrids = get(ActiveViews,{'AxesGrid'});
AxGrids = cat(1,AxGrids{:});
CurrentState = get(AxGrids,{'LimitManager'});
set(AxGrids,'LimitManager','off')   

% Refresh models
% RE: Not enough to update visible models (hidden models would be out of
%     sync when made visible
ModelData = looptransfers(LoopData,RespList(:,1));
for ct=1:length(this.Systems)
   src = this.Systems(ct);
   if isequal(src.Model,ModelData{ct})
      % RE: Beware that models are uptodate when exiting drag-edit mode
      src.send('SourceChanged')  % force clear data
   else
      src.Model = ModelData{ct};
   end
end

% Refresh each view
% RE: Explicit DRAW to force update when leaving drag-edit mode
set(AxGrids,{'LimitManager'},CurrentState)   
for ax=AxGrids'
   ax.send('ViewChanged')
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(eventsrc,eventdata,this)
% Callback to dynamic gain update start/finish events
if strcmp(this.RealTimeEnable,'on') & strcmp(get(this.Figure,'Visible'),'on')
   this.refreshgain(eventdata.Data{[2 1]})  % e.g., 'init','C'
end
    

%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(eventsrc,eventdata,this)
% Notifies editors of MOVEPZ:init and MOVEPZ:finish events
if strcmp(this.RealTimeEnable,'on') & strcmp(get(this.Figure,'Visible'),'on')
   this.refreshpz(eventdata.Data{2:end})
end
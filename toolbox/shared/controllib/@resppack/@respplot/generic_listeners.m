function generic_listeners(this)
%GENERIC_LISTENERS  Installs generic listeners for @respplot class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:33 $

% Base class listeners
% REVISIT: ::addlisteners(this)
init_listeners(this);

% I/O names
ioname = [this.findprop('InputName') ; this.findprop('OutputName')];
L1 = [handle.listener(this, ioname, 'PropertyPostSet', @rclabel);...
      handle.listener(this, this.findprop('IOGrouping'),...
      'PropertyPostSet', @LocalAxesGrouping)];
set(L1, 'CallbackTarget', this);

% I/O visibility
iovis = [this.findprop('InputVisible');this.findprop('OutputVisible')];
L2 = [handle.listener(this, iovis, 'PropertyPostSet', {@LocalRefreshPlot this})];

this.Listeners = [this.Listeners ; L1; L2];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Re-parent the line handles to conform with current AxesGrouping mode.
% ----------------------------------------------------------------------------%
function LocalAxesGrouping(this, eventdata)
% Reparent views and characteristics
Axes = getaxes(this); 
for r=allwaves(this)'
   reparent(r,Axes);
end

% Reparent background lines
nax = prod(size(Axes));
nobj = prod(size(this.BackgroundLines))/nax;
BackLines = reshape(this.BackgroundLines,[nax nobj]);
for ct=1:nax*(nobj>0)
   set(BackLines(ct,:),'Parent',Axes(ct))
end

% Adjust visibility (manual vis. management for grouped axes)
refresh(this)

% Set actual axes grouping.
RespGrouping = {'none', 'all', 'inputs',  'outputs'};
AxesGrouping = {'none', 'all', 'column', 'row'};
idx = find(strcmp(this.IOGrouping, RespGrouping));
this.AxesGrid.AxesGrouping = AxesGrouping{idx};
% RE: this last statement triggers call to AXESGRID/REFRESH and ViewChanged event


% ----------------------------------------------------------------------------%
% Purpose: Updates visibility of HG objects (axes, curves) when visible grid changes
% ----------------------------------------------------------------------------%
function LocalRefreshPlot(eventsrc,eventdata,this)
% Updates g-object visibility when axes visibility changes.
% RE: InputVisible/OutputVisible shadow RowVisible/ColumnVisible (the latter 
%     won't correctly update response curve vis. when set direclty)

% Pass new settings down to @axesgrid object
% RE: 1) Issues ViewChanged event which triggers limit update
%     2) REFRESH must be performed prior to updating AxesGrid properties in order
%        to properly set the response curve visibility prior to updating the 
%        limits (ViewChanged event's side effect)
switch eventsrc.Name
case 'InputVisible'
   if any(strcmp(this.IOGrouping,{'all','inputs'}))
      % Visibility of HG objects must be explicitly adjusted for grouped
      % axes (visibility of parent axes does not change in this case)
      refresh(this)
   end
   Cvis = this.io2rcvis('c',eventdata.NewValue);
   this.AxesGrid.ColumnVisible = Cvis;
   
case 'OutputVisible'
   if any(strcmp(this.IOGrouping,{'all','outputs'}))
      refresh(this)
   end
   Rvis = this.io2rcvis('r',eventdata.NewValue);
   this.AxesGrid.RowVisible = Rvis;
end
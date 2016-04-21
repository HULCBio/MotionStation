function addlisteners(this, listeners)
%ADDLISTENERS  Installs listeners for @waveform class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:05 $

if nargin == 1
   % Install generic DATAVIEW listeners
   generic_listeners(this)
   
   % Event listeners
   L1 = handle.listener(this, 'ObjectBeingDestroyed', @LocalCleanUp);
   
   % Source- and style-related listeners
   % ATTN: SourceObject must be updated when DataSrc or Style change
   LocalSrcChgListener(this);
   %LocalStyleChgListener(this);  not needed - Style=[] initially
   L2 = [handle.listener(this, this.findprop('DataSrc'), ...
         'PropertyPostSet', @LocalSrcChgListener);...
         handle.listener(this, this.findprop('Style'), ...
         'PropertyPostSet', @LocalStyleChgListener)];
   
   % Other listeners
   indices = [this.findprop('RowIndex'); this.findprop('ColumnIndex')]; 
   L3 = [handle.listener(this, this.findprop('RefreshMode'), ...
         'PropertyPostSet', @LocalRefreshMode);...
         handle.listener(this, this.findprop('Visible'), ...
         'PropertyPostSet', @LocalVisible); ...
         handle.listener(this.View, this.View(1).findprop('Visible'), ...
         'PropertyPostSet', @LocalViewVisible); ... 
          handle.listener(this, indices, 'PropertyPostSet', @LocalIndex)];
   
   % Target listeners
   listeners = [L1 ; L2 ; L3];
   set(listeners, 'CallbackTarget', this);
end

this.Listeners = [this.Listeners ; listeners];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Clean up when @waveform object is destroyed.
% ----------------------------------------------------------------------------%
function LocalCleanUp(this, eventdata)
delete(this.Characteristics(ishandle(this.Characteristics)))
% ATTN: this.View and this.Data are deleted in parent class destructor
% dataview::LocalCleanUp.


% ----------------------------------------------------------------------------%
% Purpose: Update SourceObject of DataSrcListener when DataSrc changes
% ----------------------------------------------------------------------------%
function LocalSrcChgListener(this, eventdata)
delete(this.DataSrcListener);
if ~isempty(this.DataSrc)
   this.DataSrcListener = ...
      handle.listener(this.DataSrc, 'SourceChanged', @LocalRedraw);
   this.DataSrcListener.CallbackTarget = this;
else
   this.DataSrcListener = [];
end


% ----------------------------------------------------------------------------%
% Purpose: Update SourceObject of StyleListener and refresh graphics
% ----------------------------------------------------------------------------%
function LocalStyleChgListener(this, eventdata)
delete(this.StyleListener);
if ~isempty(this.Style)
   this.StyleListener = ...
      handle.listener(this.Style, 'StyleChanged', @applystyle);
   this.StyleListener.CallbackTarget = this;
   % Update graphics
   applystyle(this)
else
   this.StyleListener = [];
end


% ----------------------------------------------------------------------------%
% Purpose: Update waveform plot when receiving a SourceChanged event
% ----------------------------------------------------------------------------%
function LocalRedraw(this, eventdata)
% Turn off DataChanged listener (for speed)
set(this.DataChangedListener,'Enable','off')

% Clear waveform data & dependencies
clear(this.Data)
for c=this.Characteristics'
    clear(c.Data)
end

% Redraw response
if strcmp(this.Visible,'on') && strcmp(this.Parent.Visible,'on') % speed-optimized
   draw(this,'nocheck')
end

% Reenable DataChanged listener
set(this.DataChangedListener,'Enable','on')

% ----------------------------------------------------------------------------%
% Purpose: Updates visibility of HG objects when waveform's visibility changes
% ----------------------------------------------------------------------------%
function LocalVisible(this, eventdata)
% Update visibility of @view objects
refresh(this)
% Redraw (limits may change)
if isvisible(this)
   draw(this)
else
   this.Parent.AxesGrid.send('ViewChanged');
end

% ----------------------------------------------------------------------------%
% Purpose: Updates visibility of HG objects when visibility of 
%          particular View changes
% ----------------------------------------------------------------------------%
function LocalViewVisible(this, eventdata)
View = eventdata.AffectedObject;
ViewVis = strcmp(View.Visible,'on');  % View visibility state
if ViewVis
   Mask = refreshmask(this);  % visibility of each response component (curve)
else
   Mask = false;
end
% Update visibility of view's HG components
View.refresh(Mask);

% Update visibility of corresponding resp. characteristic views
idx = find(View == this.View);
% REVISIT: next line should work when this.Characteristics initialized to handle(0,1)
% for c = find(this.Characteristics,'Visible','on')'
for c = this.Characteristics(strcmp(get(this.Characteristics,'Visible'),'on'))'
   c.View(idx).refresh(Mask);
end

% Redraw (limits may change)
if ViewVis & isvisible(this)
   draw(this)
else
   this.Parent.AxesGrid.send('ViewChanged');
end

% ----------------------------------------------------------------------------%
% Purpose:  Propagate RefreshMode to dependencies
% ----------------------------------------------------------------------------%
function LocalRefreshMode(this, eventdata)
% Propagate to characteristics
set(this.Characteristics,'RefreshMode',eventdata.NewValue)

% Purpose: Reparent waveform to appropriate axes when RowIndex/ColumnIndex changes 
% ----------------------------------------------------------------------------% 
function LocalIndex(this, eventdata) 
reparent(this) 
this.Parent.AxesGrid.send('ViewChanged'); 

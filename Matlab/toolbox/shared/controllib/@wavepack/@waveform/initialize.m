function initialize(this,Nwaves)
%INITIALIZE  Initializes @waveform instance.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:13 $

% RE: Assumes all size check already performed

% Concrete Factory Method to create adequate @data and @view objects
[this.Data, this.View, DataProps] = createdataview(this.Parent,Nwaves);

% Initialize @view objects
Axes = getaxes(this);
for ct = 1:Nwaves
   initialize(this.View(ct),Axes); 
end

% Install listeners (generic + @waveform-specific)
addlisteners(this)

% Install listener to data changes
% RE: Can be switched off to avoid excessive traffic when clear all data
%     in waveform array
L1 = handle.listener(this.Data, DataProps,'PropertyPostSet', @LocalNotify);
L1.CallbackTarget = this;
L2 = handle.listener(this, 'DataChanged', @LocalClearDependencies);
this.DataChangedListener = [L1;L2];
   
% Initialize (effective) visibility of HG objects
refresh(this)


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Notify peers of change in wave data (this = @waveform object)
% ----------------------------------------------------------------------------%
function LocalNotify(this, eventdata)
if ~isempty(eventdata.NewValue)
  % Find out which data object was changed in response array
  idx = find(eventdata.AffectedObject == this.Data);  
  % REVISIT: simplify when send(event, data) supported
  this.send('DataChanged', ctrluis.dataevent(this, 'DataChanged', idx));
end

% ----------------------------------------------------------------------------%
% Purpose:  Clear characteristic data when waveform data changes
% ----------------------------------------------------------------------------%
function LocalClearDependencies(this,eventdata)
% DaataChanged listener callback
idx = eventdata.Data;  % this.Data(idx) has changed
for c=this.Characteristics'
    clear(c.Data(idx))
end


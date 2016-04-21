function UnitBox = editUnits(this,BoxLabel,BoxPool,Data)
%EDITUNITS  Builds group box for Units

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:20 $

% Build standard Unit box
UnitBox = this.AxesGrid.editUnits(BoxLabel,BoxPool,'NicholsUnits',localGetData(this));

%---Listener on the AxesGrid to listen to change in Units/Scale
%   Properties (Units) from the AxesGrid of the Plot or otherwise
props = [findprop(this,'FrequencyUnits');...
      findprop(this.AxesGrid,'XUnits')];
UnitBox.TargetListener =...
   [handle.listener(this,props,'PropertyPostSet',{@localReadProp this,UnitBox});...
      handle.listener(UnitBox,findprop(UnitBox,'Data'),...
      'PropertyPostSet',{@localWriteProp this,UnitBox})];
% Initialization
s = get(UnitBox.GroupBox,'UserData');
s.FrequencyUnits.select(strcmpi(this.FrequencyUnits(1),'r'));
s.PhaseUnits.select(strcmpi(this.AxesGrid.XUnits(1),'r'));
GL = java.awt.GridLayout(s.Units.getComponentCount,1,0,3);
s.Units.setLayout(GL);
s.Scale.setLayout(GL);

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localReadProp %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,Plot,UnitBox)
% Write Affected Object Data into the Groupbox Data
UnitBox.Data = localGetData(Plot);

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localWritePropGBtoData %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,Plot,UnitBox)
% Read GroupBox Data into the Affected Object
Plot.FrequencyUnits = UnitBox.Data.FrequencyUnits;
Plot.AxesGrid.XUnits = UnitBox.Data.PhaseUnits;

%%%%%%%%%%%%%%%%
% localGetData %
%%%%%%%%%%%%%%%%
function Data = localGetData(this)
Data = struct('FrequencyUnits',this.FrequencyUnits,...
      'PhaseUnits',this.AxesGrid.XUnits);
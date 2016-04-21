function UnitBox = editUnits(this,BoxLabel,BoxPool,Data)
%EDITUNITS  Builds group box for Units

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:19 $

% Build standard Unit box
AxGrid = this.AxesGrid;
UnitBox = AxGrid.editUnits(BoxLabel,BoxPool,'BodeUnits',localGetData(AxGrid));

%---Listener on the AxesGrid to listen to change in Units/Scale
%   Properties (Units) from the AxesGrid of the plot or otherwise
props = [findprop(AxGrid,'XUnits') ; findprop(AxGrid,'YUnits');...
      findprop(AxGrid,'XScale') ; findprop(AxGrid,'YScale')];
UnitBox.TargetListener =...
   [handle.listener(AxGrid,props,'PropertyPostSet',{@localReadProp AxGrid,UnitBox});...
      handle.listener(UnitBox,findprop(UnitBox,'Data'),'PropertyPostSet',{@localWriteProp AxGrid,UnitBox})];

% Initialization
s = get(UnitBox.GroupBox,'UserData');
s.FrequencyUnits.select(strcmp(AxGrid.XUnits(1),'r'));
s.MagnitudeUnits.select(strcmp(AxGrid.YUnits{1},'abs'));
if strcmp(AxGrid.YUnits{1},'dB')
   s.MagnitudeScalePanel.setVisible(0);
else
   s.MagnitudeScalePanel.setVisible(1);
end
s.PhaseUnits.select(strcmp(AxGrid.YUnits{2},'rad'));
s.FrequencyScale.select(strcmp(AxGrid.XScale{1},'log'));
s.MagnitudeScale.select(strcmp(AxGrid.YScale{1},'log'));
GL = java.awt.GridLayout(s.Units.getComponentCount,1,0,3);
s.Units.setLayout(GL);
s.Scale.setLayout(GL);

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localReadProp %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,AxGrid,UnitBox)
% Write Affected Object Data into the Groupbox Data
UnitBox.Data = localGetData(AxGrid); 

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localWritePropGBtoData %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,AxGrid,UnitBox)
% Read GroupBox Data into the Affected Object
set(UnitBox.TargetListener,'enable','off')
Data = UnitBox.Data;
AxGrid.XUnits = Data.FrequencyUnits;
AxGrid.YUnits = {Data.MagnitudeUnits ; Data.PhaseUnits};
AxGrid.XScale = repmat({Data.FrequencyScale},[length(AxGrid.XScale) 1]);
AxGrid.YScale = repmat({Data.MagnitudeScale ; AxGrid.YScale{2}},[length(AxGrid.YScale)/2 1]);
set(UnitBox.TargetListener,'enable','on')

%%%%%%%%%%%%%%%%
% localGetData %
%%%%%%%%%%%%%%%%
function Data = localGetData(AxGrid)
Data = struct('FrequencyUnits',AxGrid.XUnits,...
   'MagnitudeUnits',AxGrid.YUnits{1},...
   'PhaseUnits',AxGrid.YUnits{2},...
   'FrequencyScale',AxGrid.XScale{1},...
   'MagnitudeScale',AxGrid.YScale{1});
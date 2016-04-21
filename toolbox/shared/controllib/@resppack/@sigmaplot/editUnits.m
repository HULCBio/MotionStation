function UnitBox = editUnits(this,BoxLabel,BoxPool,Data)
%EDITUNITS  Builds group box for Units

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:13 $

% Build standard Unit box
[Data,BoxTag] = LocalGetUnits(this);
UnitBox = this.AxesGrid.editUnits(BoxLabel,BoxPool,'SigmaUnits',Data);
UnitBox.Tag = BoxTag;
if ~isempty(Data)
   %---Listener on the AxesGrid to listen to change in Units/Scale
   %   Properties (Units) from the AxesGrid of the Plot or otherwise
   props = [findprop(this.AxesGrid,'XUnits');...
         findprop(this.AxesGrid,'YUnits');...
         findprop(this.AxesGrid,'XScale');...
         findprop(this.AxesGrid,'YScale')];
   UnitBox.TargetListener =...
      [handle.listener(this.AxesGrid,props,'PropertyPostSet',{@localReadProp this.AxesGrid,UnitBox});...
         handle.listener(UnitBox,findprop(UnitBox,'Data'),'PropertyPostSet',{@localWriteProp this.AxesGrid,UnitBox})];
   % Initialization
   s = get(UnitBox.GroupBox,'UserData');
   s.FrequencyUnits.select(strcmpi(this.AxesGrid.XUnits(1),'r'));
   s.MagnitudeUnits.select(strcmpi(this.AxesGrid.YUnits(1),'a'));
   s.FrequencyScale.select(strcmpi(this.AxesGrid.XScale{1},'log'));
   s.MagnitudeScale.select(strcmpi(this.AxesGrid.YScale{1},'log'));
   GL = java.awt.GridLayout(s.Units.getComponentCount,1,0,3);
   s.Units.setLayout(GL);
   s.Scale.setLayout(GL);
else
   return;
end

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localReadProp %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,Plot,OptionsBox)
% Write Affected Object Data into the Groupbox Data
OptionsBox.Data = struct('FrequencyUnits',Plot.XUnits,...
   'MagnitudeUnits',Plot.YUnits,...
   'FrequencyScale',Plot.XScale{1},...
   'MagnitudeScale',Plot.YScale{1});

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % localWritePropGBtoData %
% %%%%%%%%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,Plot,OptionsBox)
% Read GroupBox Data into the Affected Object
set(OptionsBox.TargetListener,'enable','off');
set(Plot,'XUnits', OptionsBox.Data.FrequencyUnits);
set(Plot,'YUnits', OptionsBox.Data.MagnitudeUnits);
set(Plot,'XScale',{OptionsBox.Data.FrequencyScale});
set(Plot,'YScale',{OptionsBox.Data.MagnitudeScale});
set(OptionsBox.TargetListener,'enable','on');

% %%%%%%%%%%%%%%%%%%%%%%%%%
% % LocalGetUnits
% %%%%%%%%%%%%%%%%%%%%%%%%%
function [Data,Label] = LocalGetUnits(this)
% Get the Units Data for @editbox

Data = struct('FrequencyUnits',this.AxesGrid.XUnits,...
   'MagnitudeUnits',this.AxesGrid.YUnits,...
   'FrequencyScale',this.AxesGrid.XScale{1},...
   'MagnitudeScale',this.AxesGrid.YScale{1});
Label = 'SigmaUnits';
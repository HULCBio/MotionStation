function UnitBox = editUnits(this,BoxLabel,BoxPool,BoxTag,Data)
%EDITUNITS  Builds group box for editing Units.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:44 $

UnitBox = find(handle(BoxPool),'Tag',BoxTag);
if isempty(UnitBox)
   % Create groupbox if not found
   UnitBox = LocalCreateUI(this,Data);
else
   UnitBox.GroupBox.setLabel(sprintf(BoxLabel))
end
UnitBox.Tag = BoxTag;
UnitBox.Target = this;
UnitBox.Data = Data;
addlisteners(UnitBox);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OptionsBox = LocalCreateUI(this,Data)
% Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
OptionsBox = cstprefs.editbox;

%---Definitions
FL_L  = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,8,0);
GL_12 = java.awt.GridLayout(1,2,8,0);
GL_31 = java.awt.GridLayout(3,1,0,3);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Units'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code Below is to create appropriate panels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---Units panel (west)
s.Units = com.mathworks.mwt.MWPanel(GL_31); 
Main.add(s.Units,com.mathworks.mwt.MWBorderLayout.WEST);
if isempty(Data)
   s.NullString = com.mathworks.mwt.MWLabel(sprintf('No units available for selected response plot.'));
   s.NullString.setFont(Prefs.JavaFontP);
   Main.add(s.NullString,com.mathworks.mwt.MWBorderLayout.NORTH);
else
   Callback = {@localWriteProp,OptionsBox};
   %  Create only the rows available as Data Fields.
   %---Frequency units
   if isfield(Data,'FrequencyUnits')
      s.FrequencyUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); 
      s.Units.add(s.FrequencyUnitsPanel);
      s.FrequencyUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Frequency in')); s.FrequencyUnitsPanel.add(s.FrequencyUnitsLabel);
      s.FrequencyUnits = com.mathworks.mwt.MWChoice; s.FrequencyUnitsPanel.add(s.FrequencyUnits);
      s.FrequencyUnits.add(sprintf('Hz')); s.FrequencyUnits.add(sprintf('rad/sec'));
      s.FrequencyUnitsLabel.setFont(Prefs.JavaFontP);
      s.FrequencyUnits.setFont(Prefs.JavaFontP);
      set(s.FrequencyUnits,'Name','FrequencyUnits','ItemStateChangedCallback',Callback);
   end
   %---Magnitude units
   if isfield(Data,'MagnitudeUnits')
      s.MagnitudeUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.MagnitudeUnitsPanel);
      s.MagnitudeUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Magnitude in')); s.MagnitudeUnitsPanel.add(s.MagnitudeUnitsLabel);
      s.MagnitudeUnits = com.mathworks.mwt.MWChoice; s.MagnitudeUnitsPanel.add(s.MagnitudeUnits);
      s.MagnitudeUnits.add(sprintf('dB')); s.MagnitudeUnits.add(sprintf('absolute'));
      s.MagnitudeUnitsLabel.setFont(Prefs.JavaFontP);
      s.MagnitudeUnits.setFont(Prefs.JavaFontP);
      set(s.MagnitudeUnits,'Name','MagnitudeUnits','ItemStateChangedCallback',Callback);
   end
   %---Phase units
   if isfield(Data,'PhaseUnits')
      s.PhaseUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.PhaseUnitsPanel);
      s.PhaseUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Phase in')); s.PhaseUnitsPanel.add(s.PhaseUnitsLabel);
      s.PhaseUnits = com.mathworks.mwt.MWChoice; s.PhaseUnitsPanel.add(s.PhaseUnits);
      s.PhaseUnits.add(sprintf('degrees')); s.PhaseUnits.add(sprintf('radians'));
      s.PhaseUnitsLabel.setFont(Prefs.JavaFontP);
      s.PhaseUnits.setFont(Prefs.JavaFontP);
      set(s.PhaseUnits,'Name','PhaseUnits','ItemStateChangedCallback',Callback);
   end
   
   %---Scale panel (center)
   s.Scale = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.Scale,com.mathworks.mwt.MWBorderLayout.CENTER);
   
   %---Frequency scale
   if isfield(Data,'FrequencyScale')
      s.FrequencyScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.FrequencyScalePanel);
      s.FrequencyScaleLabel = com.mathworks.mwt.MWLabel(sprintf('using')); s.FrequencyScalePanel.add(s.FrequencyScaleLabel);
      s.FrequencyScale = com.mathworks.mwt.MWChoice; s.FrequencyScalePanel.add(s.FrequencyScale);
      s.FrequencyScale.add(sprintf('linear scale')); s.FrequencyScale.add(sprintf('log scale'));
      s.FrequencyScaleLabel.setFont(Prefs.JavaFontP);
      s.FrequencyScale.setFont(Prefs.JavaFontP);
      set(s.FrequencyScale,'Name','FrequencyScale','ItemStateChangedCallback',Callback);
   end
   %---Magnitude scale
   if isfield(Data,'MagnitudeScale')
      s.MagnitudeScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.MagnitudeScalePanel);
      s.MagnitudeScaleLabel = com.mathworks.mwt.MWLabel(sprintf('using')); s.MagnitudeScalePanel.add(s.MagnitudeScaleLabel);
      s.MagnitudeScale = com.mathworks.mwt.MWChoice; s.MagnitudeScalePanel.add(s.MagnitudeScale);
      s.MagnitudeScale.add(sprintf('linear scale')); s.MagnitudeScale.add(sprintf('log scale'));
      s.MagnitudeScaleLabel.setFont(Prefs.JavaFontP);
      s.MagnitudeScale.setFont(Prefs.JavaFontP);
      set(s.MagnitudeScale,'Name','MagnitudeScale','ItemStateChangedCallback',Callback);
   end
end

%---Store java handles
set(Main,'UserData',s);
OptionsBox.GroupBox = Main;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalWriteProp 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,OptionsBox)
% Update Data Property when GUI changes
Data = OptionsBox.Data;
switch get(eventSrc,'Name')
case 'FrequencyUnits'
   if get(eventSrc,'SelectedIndex')==0
      Value = 'Hz';
   else
      Value = 'rad/sec';
   end
   Data.FrequencyUnits = Value;
case 'MagnitudeUnits'
   if get(eventSrc,'SelectedIndex')==0
      Value = 'dB';
      Data.MagnitudeScale = 'linear';
   else
      Value = 'abs';
   end
   Data.MagnitudeUnits = Value;
case 'PhaseUnits'
   if get(eventSrc,'SelectedIndex')==0
      Value = 'deg';
   else
      Value = 'rad';
   end
   Data.PhaseUnits = Value;
case 'FrequencyScale'
   if get(eventSrc,'SelectedIndex')==0
      Value = 'linear';
   else
      Value = 'log';
   end
   Data.FrequencyScale = Value;
case 'MagnitudeScale'
   if get(eventSrc,'SelectedIndex')==0
      Value = 'linear';
   else
      Value = 'log';
   end
   Data.MagnitudeScale = Value;
end
OptionsBox.Data = Data;

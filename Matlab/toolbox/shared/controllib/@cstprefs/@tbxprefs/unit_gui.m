function Main = unit_gui(h)
%UNIT_GUI  GUI for editing unit & scale properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:56 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
FL_L  = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,8,0);
GL_12 = java.awt.GridLayout(1,2,8,0);
GL_31 = java.awt.GridLayout(3,1,0,3);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Units'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Units panel (west)
s.Units = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.Units,com.mathworks.mwt.MWBorderLayout.WEST);
   %---Frequency units
    s.FrequencyUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.FrequencyUnitsPanel);
    s.FrequencyUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Frequency in')); s.FrequencyUnitsPanel.add(s.FrequencyUnitsLabel);
    s.FrequencyUnits = com.mathworks.mwt.MWChoice; s.FrequencyUnitsPanel.add(s.FrequencyUnits);
    s.FrequencyUnits.add(sprintf('Hz')); s.FrequencyUnits.add(sprintf('rad/sec'));
    s.FrequencyUnitsLabel.setFont(Prefs.JavaFontP);
    s.FrequencyUnits.setFont(Prefs.JavaFontP);
   %---Magnitude units
    s.MagnitudeUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.MagnitudeUnitsPanel);
    s.MagnitudeUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Magnitude in')); s.MagnitudeUnitsPanel.add(s.MagnitudeUnitsLabel);
    s.MagnitudeUnits = com.mathworks.mwt.MWChoice; s.MagnitudeUnitsPanel.add(s.MagnitudeUnits);
    s.MagnitudeUnits.add(sprintf('dB')); s.MagnitudeUnits.add(sprintf('absolute'));
    s.MagnitudeUnitsLabel.setFont(Prefs.JavaFontP);
    s.MagnitudeUnits.setFont(Prefs.JavaFontP);
   %---Phase units
    s.PhaseUnitsPanel = com.mathworks.mwt.MWPanel(GL_12); s.Units.add(s.PhaseUnitsPanel);
    s.PhaseUnitsLabel = com.mathworks.mwt.MWLabel(sprintf('Phase in')); s.PhaseUnitsPanel.add(s.PhaseUnitsLabel);
    s.PhaseUnits = com.mathworks.mwt.MWChoice; s.PhaseUnitsPanel.add(s.PhaseUnits);
    s.PhaseUnits.add(sprintf('degrees')); s.PhaseUnits.add(sprintf('radians'));
    s.PhaseUnitsLabel.setFont(Prefs.JavaFontP);
    s.PhaseUnits.setFont(Prefs.JavaFontP);

%---Scale panel (center)
s.Scale = com.mathworks.mwt.MWPanel(GL_31); Main.add(s.Scale,com.mathworks.mwt.MWBorderLayout.CENTER);
   %---Frequency scale
    s.FrequencyScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.FrequencyScalePanel);
    s.FrequencyScaleLabel = com.mathworks.mwt.MWLabel(sprintf('using')); s.FrequencyScalePanel.add(s.FrequencyScaleLabel);
    s.FrequencyScale = com.mathworks.mwt.MWChoice; s.FrequencyScalePanel.add(s.FrequencyScale);
    s.FrequencyScale.add(sprintf('linear scale')); s.FrequencyScale.add(sprintf('log scale'));
    s.FrequencyScaleLabel.setFont(Prefs.JavaFontP);
    s.FrequencyScale.setFont(Prefs.JavaFontP);
   %---Magnitude scale
    s.MagnitudeScalePanel = com.mathworks.mwt.MWPanel(FL_L); s.Scale.add(s.MagnitudeScalePanel);
    s.MagnitudeScaleLabel = com.mathworks.mwt.MWLabel(sprintf('using')); s.MagnitudeScalePanel.add(s.MagnitudeScaleLabel);
    s.MagnitudeScale = com.mathworks.mwt.MWChoice; s.MagnitudeScalePanel.add(s.MagnitudeScale);
    s.MagnitudeScale.add(sprintf('linear scale')); s.MagnitudeScale.add(sprintf('log scale'));
    s.MagnitudeScaleLabel.setFont(Prefs.JavaFontP);
    s.MagnitudeScale.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---Frequency Units
    s.FrequencyUnitsListener = handle.listener(h,CLS.findprop('FrequencyUnits'),'PropertyPostSet',Callback);
    set(s.FrequencyUnits,'Name','FrequencyUnits','ItemStateChangedCallback',GUICallback);
   %---Magnitude Units
    s.MagnitudeUnitsListener = handle.listener(h,CLS.findprop('MagnitudeUnits'),'PropertyPostSet',Callback);
    set(s.MagnitudeUnits,'Name','MagnitudeUnits','ItemStateChangedCallback',GUICallback);
   %---Phase Units
    s.PhaseUnitsListener = handle.listener(h,CLS.findprop('PhaseUnits'),'PropertyPostSet',Callback);
    set(s.PhaseUnits,'Name','PhaseUnits','ItemStateChangedCallback',GUICallback);
   %---Frequency Scale
    s.FrequencyScaleListener = handle.listener(h,CLS.findprop('FrequencyScale'),'PropertyPostSet',Callback);
    set(s.FrequencyScale,'Name','FrequencyScale','ItemStateChangedCallback',GUICallback);
   %---Magnitude Scale
    s.MagnitudeScaleListener = handle.listener(h,CLS.findprop('MagnitudeScale'),'PropertyPostSet',Callback);
    set(s.MagnitudeScale,'Name','MagnitudeScale','ItemStateChangedCallback',GUICallback);

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
Name = eventSrc.Name;
NewValue = eventData.NewValue;
%---Set GUI state
switch Name
case 'FrequencyUnits'
   if strcmpi(eventData.NewValue(1),'h')
      s.FrequencyUnits.select(0);
   else
      s.FrequencyUnits.select(1);
   end
case 'MagnitudeUnits'
   h = eventData.AffectedObject;
   if strcmpi(eventData.NewValue(1),'d')
      s.MagnitudeUnits.select(0);
      s.MagnitudeScalePanel.setVisible(0);
      h.MagnitudeScale = 'linear';
   else
      s.MagnitudeUnits.select(1);
      h.MagnitudeScale = 'linear';
      s.MagnitudeScalePanel.setVisible(1);
   end
case 'PhaseUnits'
   if strcmpi(eventData.NewValue(1),'d')
      s.PhaseUnits.select(0);
   else
      s.PhaseUnits.select(1);
   end
case 'FrequencyScale'
   if strcmpi(eventData.NewValue,'linear')
      s.FrequencyScale.select(0);
   else
      s.FrequencyScale.select(1);
   end
case 'MagnitudeScale'
   if strcmpi(eventData.NewValue,'linear')
      s.MagnitudeScale.select(0);
   else
      s.MagnitudeScale.select(1);
   end
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
Name = get(eventSrc,'Name');
switch Name
case {'FrequencyUnits'}
   if get(eventSrc,'SelectedIndex')==0
      Value = 'Hz';
   else
      Value = 'rad/sec';
   end
case {'MagnitudeUnits'}
   if get(eventSrc,'SelectedIndex')==0
      Value = 'dB';
   else
      Value = 'abs';
   end
case {'PhaseUnits'}
   if get(eventSrc,'SelectedIndex')==0
      Value = 'deg';
   else
      Value = 'rad';
   end
case {'FrequencyScale','MagnitudeScale'}
   if get(eventSrc,'SelectedIndex')==0
      Value = 'linear';
   else
      Value = 'log';
   end
end
set(h,Name,Value);

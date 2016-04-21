function TextBox = editAspectRatio(this,BoxLabel,BoxPool)
% EDITASPECTRATIO  Builds group box for editing Aspect ratio of the plot.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 04:58:50 $

TextBox = find(handle(BoxPool),'Tag','Aspect Ratio');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'Aspect Ratio';

% Targeting
TextBox.Target = this;
props = [findprop(this,'AxisEqual')];
TextBox.TargetListeners = ...
   handle.listener(this,props,'PropertyPostSet',{@localReadProp TextBox});

% Initialization
s = get(TextBox.GroupBox,'UserData');
set(s.AxisEqual,'State',get(this,'AxisEqual'));

%------------------ Local Functions ------------------------

function OptionsBox = LocalCreateUI()

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
s.Main = com.mathworks.mwt.MWGroupbox(sprintf('Aspect Ratio'));
s.Main.setLayout(java.awt.GridLayout(1,1,0,3));
s.Main.setFont(Prefs.JavaFontB);

%---Checkboxes
s.AxisEqual = com.mathworks.mwt.MWCheckbox(sprintf('Equal'));
s.AxisEqual.setFont(Prefs.JavaFontP);
s.Main.add(s.AxisEqual);
s.AxisEqualTT = com.mathworks.mwt.MWToolTip(s.AxisEqual,sprintf('Force equal X-Y data aspect ratio'));

%---Store java handles
set(s.Main,'UserData',s);

%---Create @editbox instance
OptionsBox = cstprefs.editbox;
OptionsBox.GroupBox = s.Main;

%---Install GUI callbacks
GUICallback = {@localWriteProp,OptionsBox};
set(s.AxisEqual,'Name','AxisEqual','ItemStateChangedCallback',GUICallback);

%---Return handle of top-level GUI
OptionsBox.GroupBox = s.Main;

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,OptionsBox)

% Target -> GUI
s = get(OptionsBox.GroupBox,'UserData');
set(s.AxisEqual,'State',eventData.NewValue);

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,OptionsBox)

% GUI -> Target
this = OptionsBox.Target;
set(this,'AxisEqual',get(eventSrc,'State'));

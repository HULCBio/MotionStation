function TextBox = editGrid(this,BoxLabel,BoxPool)
%EDITLABELS  Builds group box for editing Labels.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:07 $

TextBox = find(handle(BoxPool),'Tag','Grid');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'Grid';

% Targeting
TextBox.Target = this;
TextBox.TargetListeners = ...
   handle.listener(this,findprop(this,'Grid'),'PropertyPostSet',{@localReadProp TextBox});

% Initialization
s = get(TextBox.GroupBox,'UserData');
GridState = this.Grid;
set(s.Grid,'State',GridState);


%------------------ Local Functions ------------------------

function OptionsBox = LocalCreateUI()

% Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
s.Main = com.mathworks.mwt.MWGroupbox(sprintf('Grid'));
s.Main.setLayout(java.awt.GridLayout(1,1,0,3));
s.Main.setFont(Prefs.JavaFontB);

%---Checkbox to toggle grid visibility
s.Grid = com.mathworks.mwt.MWCheckbox(sprintf('Show grid'));
s.Grid.setFont(Prefs.JavaFontP);
s.Main.add(s.Grid);

%---Store java handles
set(s.Main,'UserData',s);

%---Create @editbox instance
OptionsBox = cstprefs.editbox;
OptionsBox.GroupBox = s.Main;

%---Install GUI callbacks
GUICallback = {@localWriteProp,OptionsBox};
set(s.Grid,         'Name','Grid',         'ItemStateChangedCallback',GUICallback);

%---Install listener for target change
s.TargetListener = handle.listener(OptionsBox,findprop(OptionsBox,'Target'),'PropertyPreSet',@localTargetPreSet);
s.TargetListener.CallbackTarget = s.Main;


%---Return handle of top-level GUI
OptionsBox.GroupBox = s.Main;


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,OptionsBox)
% Target -> GUI
s = get(OptionsBox.GroupBox,'UserData');
switch eventSrc.Name
case 'Grid'
   GridState = eventData.NewValue;
   set(s.Grid,'State',GridState);
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,OptionsBox)
% GUI -> Target
switch get(eventSrc,'Name')
case 'Grid'
   OptionsBox.Target.Grid = get(eventSrc,'State');
end


%%%%%%%%%%%%%%%%%%%%%
% localTargetPreSet %
%%%%%%%%%%%%%%%%%%%%%
function localTargetPreSet(eventSrc,eventData)
% Update listeners when Target changes
%---New target
t = eventData.NewValue;
%---Get structure
s = get(eventSrc,'UserData');
%---Update listener
if isa(t,'sisogui.grapheditor')
   ax = t.Axes;
   s.GridListener    = handle.listener(ax,findprop(ax,'Grid'),'PropertyPostSet',{@localReadProp s.Grid});
   %---Sync
   GridOn = strcmpi(ax.Grid,'on');
   s.Grid.setState(GridOn);
else
   %---Clear
   s.GridListener = [];
end
%---Save structure
set(eventSrc,'UserData',s);

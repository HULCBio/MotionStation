function TextBox = editChars(this,BoxLabel,BoxPool)
%EDITCHARS  Builds group box for editing Characteristics.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:19 $

% Look for a group box with matching Tag in the pool of group boxes

TextBox = find(handle(BoxPool),'Tag',BoxLabel);
if isempty(TextBox)
   % Create group box if not found
   TextBox = LocalCreateUI(this);
end
    
%%%%%%%%%%%%% Targeting CallBacks.... (Write the Plot Properties into the GUI) %%%%%%%%%%%
TextBox.Target = this;
TextBox.TargetListeners = ...
   [handle.listener(this,findprop(this,'Preferences'),'PropertyPostSet',{@localReadProp TextBox,this})];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = get(TextBox.GroupBox,'UserData');

% Initialization.....................
s.UnwrapPhase.setState(strcmpi(this.Preferences.UnwrapPhase,'on'));

%------------------ Local Functions ------------------------
function TextBox = LocalCreateUI(h)

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
TextBox = cstprefs.editbox;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Phase Wrapping'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Checkbox
s.UnwrapPhase = com.mathworks.mwt.MWCheckbox(sprintf('Unwrap phase'));
s.UnwrapPhase.setFont(Prefs.JavaFontP);
Main.add(s.UnwrapPhase,com.mathworks.mwt.MWBorderLayout.WEST);

%--- GUI CallBacks.... (Write the GUI Values into the Plot Properties)
GUICallback = {@localWriteProp,TextBox};
set(s.UnwrapPhase,'Name','UnwrapPhase','ItemStateChangedCallback',GUICallback);

%---Store java handles
set(Main,'UserData',s);
TextBox.GroupBox = Main;
TextBox.Tag = 'Characteristics';

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox,h)
% Update GUI when property changes
GUI = get(TextBox.GroupBox,'UserData');
Prefs = eventData.NewValue;
GUI.UnwrapPhase.setState(strcmpi(Prefs.UnwrapPhase,'on'));

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,TextBox)
% Update property when GUI changes
UnwrapPhase = get(eventSrc,'State');
prefs = struct('UnwrapPhase',UnwrapPhase);
TextBox.Target.Preferences = prefs;
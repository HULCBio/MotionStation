function TextBox = editGridOptions(this,BoxLabel,BoxPool)
% EDITGRIDOPTIONS  Builds group box for editing Grid Options in the Options 
%                  Tab. 
%                  1) Show Grid Option
%                  2) Display damping Ratio as Percent Overshoot.

% Author (s): Kamesh Subbarao
% Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 04:58:52 $
TextBox = find(handle(BoxPool),'Tag','GridOptions');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'GridOptions';

% Targeting
TextBox.Target = this;
props = [findprop(this.Axes,'Grid');findprop(this,'GridOptions')];
TextBox.TargetListeners = ...
   [handle.listener(this.Axes,props(1),'PropertyPostSet',{@localReadProp TextBox});...
      handle.listener(this,props(2)   ,'PropertyPostSet',{@localReadProp TextBox})];

% Initialization
s = get(TextBox.GroupBox,'UserData');
GridLabel  = s.GridLabelType;
%
GridLabelOpt = get(this,'GridOptions'); 
GridState = strcmpi(this.Axes.Grid,'on');
if GridState
   set(s.Grid,'State','on');
   GridLabel.setEnabled(GridState);
   GridLabelTypeState = strcmpi(GridLabelOpt.GridLabelType,'overshoot');
   if GridLabelTypeState
      set(s.GridLabelType,'State','on');
   else
      set(s.GridLabelType,'State','off');
   end
else
   set(s.Grid,'State','off');
   GridLabel.setEnabled(GridState);
end

%------------------ Local Functions ------------------------

function OptionsBox = LocalCreateUI()

% Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
s.Main = com.mathworks.mwt.MWGroupbox(sprintf('Grid'));
s.Main.setLayout(java.awt.GridLayout(2,1,0,3));
s.Main.setFont(Prefs.JavaFontB);

%---Checkbox to toggle grid visibility
s.Grid = com.mathworks.mwt.MWCheckbox(sprintf('Show grid'));
s.Grid.setFont(Prefs.JavaFontP);
s.Main.add(s.Grid);
s.GridLabelType = com.mathworks.mwt.MWCheckbox(sprintf('Display damping values as %% peak overshoot'));
s.GridLabelType.setFont(Prefs.JavaFontP);
s.Main.add(s.GridLabelType);

%---Create @editbox instance
OptionsBox = cstprefs.editbox;

%---Install GUI callbacks
GUICallback = {@localWriteProp,OptionsBox};
set(s.Grid,         'Name','Grid',         'ItemStateChangedCallback',GUICallback);
set(s.GridLabelType,'Name','GridLabelType','ItemStateChangedCallback',GUICallback);

%---Store java handles
set(s.Main,'UserData',s);

%---Return handle of top-level GUI
OptionsBox.GroupBox = s.Main;

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%

function localReadProp(eventSrc,eventData,OptionsBox)

% Target -> GUI
s = get(OptionsBox.GroupBox,'UserData');
GridLabel    = s.GridLabelType;
GridLabelOpt = get(OptionsBox.Target,'GridOptions');
switch eventSrc.Name
case 'Grid'
   GridState = strcmpi(eventData.NewValue,'on');
   if GridState
      set(s.Grid,'State','on');
   else
      set(s.Grid,'State','off');
   end   
   GridLabel.setEnabled(GridState)
case 'GridOptions'
   GridLabelTypeState = ...
      strcmpi(eventData.NewValue.GridLabelType,'overshoot');
   if GridLabelTypeState
      set(s.GridLabelType,'State','on');
   else
      set(s.GridLabelType,'State','off');
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%

function localWriteProp(eventSrc,eventData,OptionsBox)

% GUI -> Target
this = OptionsBox.Target;
switch get(eventSrc,'Name')
case 'Grid'
   set(this.Axes,'Grid',get(eventSrc,'State'));
case 'GridLabelType'
   GridOPt = get(this,'GridOptions');
   if strcmpi(get(eventSrc,'State'),'on')
      GridOpt.GridLabelType = 'overshoot';
   else
      GridOpt.GridLabelType = 'damping';
   end
   set(this,'GridOptions',GridOpt);
end

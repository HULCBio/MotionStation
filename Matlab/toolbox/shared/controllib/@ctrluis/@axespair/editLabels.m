function TextBox = editLabels(this,BoxLabel,BoxPool)
%EDITLABELS  Builds group box for editing axes labels.
%
%   TEXTBOX = this.EDITLABELS(GroupBoxLabel,GroupBoxPool) returns the
%   handle TEXTBOX of a group box for editing the title and labels of
%   the axesgroup this.  TEXTBOX is an @editbox instance.
%
%   The group box label is specified by GroupBoxLabel, and EDITLABELS 
%   first scans the group box handle vector GroupBoxPool for a matching 
%   group box (avoids recreating the group box if it already exists, e.g., 
%   in the corresponding property editor tab).

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:30 $

% Look for a group box with matching Tag in the pool of group boxes
TextBox = find(handle(BoxPool),'Tag','TXY1Y2-Labels');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'TXY1Y2-Labels';

% Targeting
TextBox.Target = this;
props = [findprop(this,'Title');findprop(this,'XLabel');findprop(this,'YLabel')];
TextBox.TargetListeners = ...
   handle.listener(this,props,'PropertyPostSet',{@localReadProp TextBox});

% Initialization
s = get(TextBox.GroupBox,'UserData');
s.Title.setText(localFormat(this.Title));
s.XLabel.setText(localFormat(this.XLabel));
s.YLabel1.setText(localFormat(this.YLabel{1}));
s.YLabel2.setText(localFormat(this.YLabel{2}));


%------------------ Local Functions ------------------------

function TextBox = LocalCreateUI()
%GUI for editing axesgroup labels

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
import com.mathworks.mwt.*;

%---Definitions
LEFT  = MWLabel.LEFT;
GL_41 = java.awt.GridLayout(4,1,0,3);

%---Top-level panel (MWGroupbox)
Main = MWGroupbox;
Main.setLayout(MWBorderLayout(10,0));
Main.setFont(Prefs.JavaFontB);

%---West panel (labels)
s.W = MWPanel(GL_41);
Main.add(s.W,MWBorderLayout.WEST);

%---Labels
s.LTP = MWPanel(MWBorderLayout(0,0)); s.W.add(s.LTP);
s.LXP = MWPanel(MWBorderLayout(0,0)); s.W.add(s.LXP);
s.LYP = MWPanel(MWBorderLayout(0,0)); s.W.add(s.LYP);
s.LT = MWLabel(sprintf('Title:'),  LEFT); s.LTP.add(s.LT,MWBorderLayout.NORTH);
s.LX = MWLabel(sprintf('X-Label:'),LEFT); s.LXP.add(s.LX,MWBorderLayout.NORTH);
s.LY = MWLabel(sprintf('Y-Label:'),LEFT); s.LYP.add(s.LY,MWBorderLayout.NORTH);
s.LT.setFont(Prefs.JavaFontP);
s.LX.setFont(Prefs.JavaFontP);
s.LY.setFont(Prefs.JavaFontP);

%---Center panel (textfields)
s.C = MWPanel(GL_41);
Main.add(s.C,MWBorderLayout.CENTER);

%---TextFields
s.Title  = MWTextArea; s.C.add(s.Title);  s.Title.setRows(2);
s.Title.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.Title.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.Title.setFont(Prefs.JavaFontP);
s.XLabel = MWTextArea; s.C.add(s.XLabel); s.XLabel.setRows(2);
s.XLabel.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.XLabel.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.XLabel.setFont(Prefs.JavaFontP);
s.YLabel1 = MWTextArea; s.C.add(s.YLabel1); s.YLabel1.setRows(2);
s.YLabel1.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel1.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel1.setFont(Prefs.JavaFontP);
s.YLabel2 = MWTextArea; s.C.add(s.YLabel2); s.YLabel2.setRows(2);
s.YLabel2.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel2.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel2.setFont(Prefs.JavaFontP);

%---Store java handles
set(Main,'UserData',s);

%---Create @editbox instance
TextBox = cstprefs.editbox;
TextBox.GroupBox = Main;

%---UI Callbacks
Callback = {@localWriteProp TextBox};
set(s.Title,'Name','Title','TextValueChangedCallback',Callback);
set(s.XLabel,'Name','XLabel','TextValueChangedCallback',Callback);
set(s.YLabel1,'TextValueChangedCallback',{@localWriteYlabel TextBox 1});
set(s.YLabel2,'TextValueChangedCallback',{@localWriteYlabel TextBox 2});


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox)
% Update GUI when axesgroup property change
s = get(TextBox.GroupBox,'UserData');
switch eventSrc.Name
case 'YLabel'
   s.YLabel1.setText(localFormat(eventData.NewValue{1}));
   s.YLabel2.setText(localFormat(eventData.NewValue{2}));
otherwise
   s.(eventSrc.Name).setText(localFormat(eventData.NewValue));
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,TextBox)
% Update property object when GUI changes
set(TextBox.TargetListeners,'Enable','off')  % Temporarily disable listeners
TextBox.Target.(get(eventSrc,'Name')) = localFormat(get(eventSrc,'Text'));
set(TextBox.TargetListeners,'Enable','on')  % Temporarily disable listeners


%%%%%%%%%%%%%%%%%%%%
% localWriteYlabel %
%%%%%%%%%%%%%%%%%%%%
function localWriteYlabel(eventSrc,eventData,TextBox,RowIndex)
% Update property object when GUI changes
set(TextBox.TargetListeners,'Enable','off')  % Temporarily disable listeners
% REVISIT: simplify
Ylabels = TextBox.Target.YLabel;
Ylabels{RowIndex} = localFormat(get(eventSrc,'Text'));
TextBox.Target.YLabel = Ylabels;
set(TextBox.TargetListeners,'Enable','on')  % Temporarily disable listeners


%%%%%%%%%%%%%%%
% localFormat %
%%%%%%%%%%%%%%%
function txt = localFormat(txt)
% Fix carriage return for pc
if ispc, 
   txt = strrep(txt,sprintf('\r\n'),sprintf('\n'));
end  

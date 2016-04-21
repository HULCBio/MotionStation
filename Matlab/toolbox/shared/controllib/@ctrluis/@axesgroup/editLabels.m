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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:08 $

% Look for a group box with matching Tag in the pool of group boxes
TextBox = find(handle(BoxPool),'Tag','TXY-Labels');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'TXY-Labels';

% Targeting
TextBox.Target = this;
props = [findprop(this,'Title');findprop(this,'XLabel');findprop(this,'YLabel')];
TextBox.TargetListeners = ...
   handle.listener(this,props,'PropertyPostSet',{@localReadProp TextBox});

% Initialization
s = get(TextBox.GroupBox,'UserData');
s.Title.setText(localReadFormat(this.Title));
s.XLabel.setText(localReadFormat(this.XLabel));
s.YLabel.setText(localReadFormat(this.YLabel));


%------------------ Local Functions ------------------------

function TextBox = LocalCreateUI()
%GUI for editing axesgroup labels

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
import com.mathworks.mwt.*;

%---Definitions
LEFT  = MWLabel.LEFT;
GL_31 = java.awt.GridLayout(3,1,0,3);

%---Top-level panel (MWGroupbox)
Main = MWGroupbox;
Main.setLayout(MWBorderLayout(10,0));
Main.setFont(Prefs.JavaFontB);

%---West panel (labels)
s.W = MWPanel(GL_31);
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
s.C = MWPanel(GL_31);
Main.add(s.C,MWBorderLayout.CENTER);

%---TextFields
s.Title  = MWTextArea; s.C.add(s.Title);  s.Title.setRows(3);
s.Title.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.Title.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.Title.setFont(Prefs.JavaFontP);
s.XLabel = MWTextArea; s.C.add(s.XLabel); s.XLabel.setRows(3);
s.XLabel.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.XLabel.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.XLabel.setFont(Prefs.JavaFontP);
s.YLabel = MWTextArea; s.C.add(s.YLabel); s.YLabel.setRows(3);
s.YLabel.setHScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel.setVScrollStyle(MWTextArea.SCROLLBAR_NEVER);
s.YLabel.setFont(Prefs.JavaFontP);

%---Save Warning state 
s.warnstate = warning;

%---Store java handles
set(Main,'UserData',s);

%---Create @editbox instance
TextBox = cstprefs.editbox;
TextBox.GroupBox = Main;

%---UI Callbacks
Callback = {@localWriteProp TextBox};
Enwarn = {@enableWarn s};
Diswarn = {@disableWarn s};

set(s.Title,'Name','Title','TextValueChangedCallback',Callback);
set(s.Title,'FocusGainedCallback',Diswarn);
set(s.Title,'FocusLostCallback',Enwarn);

set(s.XLabel,'Name','XLabel','TextValueChangedCallback',Callback);
set(s.XLabel,'FocusGainedCallback',Diswarn);
set(s.XLabel,'FocusLostCallback',Enwarn);

set(s.YLabel,'Name','YLabel','TextValueChangedCallback',Callback);
set(s.YLabel,'FocusGainedCallback',Diswarn);
set(s.YLabel,'FocusLostCallback',Enwarn);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox)
% Update GUI when axesgroup property change
s = get(TextBox.GroupBox,'UserData');
s.(eventSrc.Name).setText(localReadFormat(eventData.NewValue));

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,TextBox)
% Update property object when GUI changes
set(TextBox.TargetListeners,'Enable','off')  % Temporarily disable listeners
Prop = get(eventSrc,'Name');
TextBox.Target.(Prop) = localWriteFormat(get(eventSrc,'Text'),TextBox.Target.(Prop));
set(TextBox.TargetListeners,'Enable','on')  % Temporarily disable listeners

%%%%%%%%%%%%%%%%%%%
% localReadFormat %
%%%%%%%%%%%%%%%%%%%
function txt = localReadFormat(txt)
% Fix carriage return for pc
if iscell(txt)
   txt = sprintf('%s ; ',txt{:});
   txt = txt(1:end-3);
end
   
%%%%%%%%%%%%%%%%%%%%
% localWriteFormat %
%%%%%%%%%%%%%%%%%%%%
function txt = localWriteFormat(txt,CurrentValue)
% Fix carriage return for pc
if ispc, 
   txt = strrep(txt,sprintf('\r\n'),sprintf('\n'));
end  
if iscell(CurrentValue)
   % Multi-entry label
   s = txt;
   txt = cell(size(CurrentValue));
   txt(:) = {''};
   for ct=1:length(CurrentValue)
      [tok,s] = strtok(s,';');
      txt{ct} = fliplr(deblank(fliplr(deblank(tok))));
      s = s(2:end);
      if isempty(s)
         break
      end
   end
end

%%%%%%%%%%%%%%
% enableWarn %
%%%%%%%%%%%%%%
function enableWarn(eventSrc,eventData,s)
% Enable warnings based upon saved state value
warning(s.warnstate);


%%%%%%%%%%%%%%
% disableWarn %
%%%%%%%%%%%%%%
function disableWarn(eventSrc,eventData,s)
% Disable all warnings while saving state
s.warnstate = warning('off','all');

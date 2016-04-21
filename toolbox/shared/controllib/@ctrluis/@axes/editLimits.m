function LimBox = editLimits(this,XY,BoxLabel,BoxPool)
%EDITLIMITS  Builds group box for editing axis limits.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:28 $

% RE: XY is the axis (X or Y), and BoxLabel is the groupbox label
Tag = sprintf('%s-Lims',XY);
LimBox = find(handle(BoxPool),'Tag',Tag);
if isempty(LimBox)
   % Create groupbox if not found
   LimBox = LocalCreateUI(this,XY);
end
LimBox.GroupBox.setLabel(sprintf(BoxLabel))
LimBox.Tag = Tag;

% Target
LimBox.Target = this;

% Target listeners
LimBox.TargetListeners = ...
   handle.listener(this,'PostLimitChanged',{@localReadProp XY LimBox});

% Initialize content
localReadProp([],[],XY,LimBox)


%------------------ Local Functions ------------------------

function LimBox = LocalCreateUI(AxesGrid,XY)
%GUI for editing axesgroup limits

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
import com.mathworks.mwt.*;

%---Definitions
LCENTER = MWLabel.CENTER;
LRIGHT  = MWLabel.RIGHT;
LLEFT   = MWLabel.LEFT;
BCENTER = MWBorderLayout.CENTER;
BWEST   = MWBorderLayout.WEST;
BEAST   = MWBorderLayout.EAST;
GL_N1 = java.awt.GridLayout(2,1,0,4);

%---Top-level panel (MWGroupbox)
Main = MWGroupbox;
Main.setFont(Prefs.JavaFontB);
Main.setLayout(MWBorderLayout(8,0));

%---Column 1 (west in Main)
s.C1 = MWPanel(GL_N1); Main.add(s.C1,BWEST);
s.AutoScaleLabel = MWLabel(sprintf('Auto-Scale:'),LLEFT); s.C1.add(s.AutoScaleLabel);
s.AutoScaleLabel.setFont(Prefs.JavaFontP);
s.LimitsLabel = MWLabel(sprintf('Limits:'),LRIGHT); s.C1.add(s.LimitsLabel);
s.LimitsLabel.setFont(Prefs.JavaFontP);

%---Center panel (center in Main, holds s.C2,s.C3)
s.Center = MWPanel(MWBorderLayout(8,0)); Main.add(s.Center,BCENTER);

%---Column 2 (west in s.Center)
s.C2 = MWPanel(GL_N1); s.Center.add(s.C2,BWEST);
s.AutoScalePanel = MWPanel(MWBorderLayout(8,0)); s.C2.add(s.AutoScalePanel);
s.AutoScale = MWCheckbox; s.AutoScalePanel.add(s.AutoScale,BWEST);
s.AutoScale.setFont(Prefs.JavaFontP);

%---Initialize struct array holding each row of limit editors
Panel = MWPanel(MWBorderLayout(5,0));  s.C2.add(Panel);
Lim1  = MWTextField(7); 
Panel.add(Lim1,MWBorderLayout.WEST);
Lim1.setFont(Prefs.JavaFontP);
LimTo = MWLabel(sprintf('to'),MWLabel.CENTER); 
Panel.add(LimTo,MWBorderLayout.CENTER);
LimTo.setFont(Prefs.JavaFontP);
Lim2  = MWTextField(7); 
Panel.add(Lim2,MWBorderLayout.EAST);
Lim2.setFont(Prefs.JavaFontP);
s.LimRows = struct('Panel',Panel,'Lim1',Lim1,'LimTo',LimTo,'Lim2',Lim2);

%---Store java handles
set(Main,'UserData',s);

%---Create @editbox instance
LimBox = cstprefs.editbox;
LimBox.GroupBox = Main;

% Callbacks
set(s.AutoScale,'ItemStateChangedCallback',{@localWriteLimMode XY LimBox});
LimCallback = {@localWriteLims XY LimBox};
set(Lim1,'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);
set(Lim2,'ActionPerformedCallback',LimCallback,'FocusLostCallback',LimCallback);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,XY,LimBox)
% Update GUI when limits change
s = get(LimBox.GroupBox,'UserData');
Axes = LimBox.Target;

% Auto-Scale status
LimMode = Axes.(sprintf('%sLimMode',XY));
s.AutoScale.setState(strcmp(LimMode,'auto'));

% Limits
if strcmpi(XY,'x')
   Limits = getxlim(Axes,1);
else
   Limits = getylim(Axes,1);
end
s.LimRows.Lim1.setText(num2str(Limits(1)));
s.LimRows.Lim2.setText(num2str(Limits(2)));
set(s.LimRows.Lim1,'UserData',Limits);


%%%%%%%%%%%%%%%%%%
% localWriteLims %
%%%%%%%%%%%%%%%%%%
function localWriteLims(eventSrc,eventData,XY,LimBox)
% Update limits of target when content of limit editors changes
s = get(LimBox.GroupBox,'UserData');
Axes = LimBox.Target;

% Get new limit values
Lim1 = localEvalLim(get(s.LimRows.Lim1,'Text'));
Lim2 = localEvalLim(get(s.LimRows.Lim2,'Text'));
CurrentLims = get(s.LimRows.Lim1,'UserData');
if ~isempty(Lim1) & ~isempty(Lim2) & Lim1<Lim2 & ~isequal(CurrentLims,[Lim1 Lim2])
   % Time to update the limits
   try
      if strcmpi(XY,'x')
         setxlim(Axes,[Lim1 Lim2])
      else
         setylim(Axes,[Lim1 Lim2])
      end
      set(s.LimRows.Lim1,'UserData',[Lim1 Lim2])
   catch
      warndlg(lasterr,'Property Editor Warning','modal')
   end
end


%%%%%%%%%%%%%%%%%%%%%
% localWriteLimMode %
%%%%%%%%%%%%%%%%%%%%%
function localWriteLimMode(eventSrc,eventData,XY,LimBox)
% Update limit modes of target when Auto-Scale state changes
s = get(LimBox.GroupBox,'UserData');
Axes = LimBox.Target;
LimModeProp = sprintf('%sLimMode',XY);

State = get(eventSrc,'State');
if strcmpi(State,'on')
   Axes.(LimModeProp) = {'auto'};
else
   Axes.(LimModeProp) = {'manual'};
end
   
   
%%%%%%%%%%%%%%%%
% localEvalLim %
%%%%%%%%%%%%%%%%
function val = localEvalLim(str)
% Evaluate string val, returning valid real scalar only, empty otherwise
if ~isempty(str)
   val = evalin('base',str,'[]');
   if ~isreal(val) | ~isfinite(val) | ~isequal(size(val),[1 1])
      val = [];
   end
else
   val = [];
end
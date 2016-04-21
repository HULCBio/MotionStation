function build(this,TabLabels)
%BUILD  Builds Property Editor for response plots.

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:05:38 $

import com.mathworks.mwt.*

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

% Structure storing handles
s = struct('Frame',[],'Buttons',[],'TabPanel',[]);
   
%---Frame
s.Frame = MWFrame(sprintf('Property Editor'));
s.Frame.setLayout(MWBorderLayout(0,0));
s.Frame.setFont(Prefs.JavaFontP);
set(s.Frame,'WindowClosingCallback',{@localClose,this});
%---Open an empty Frame with some status text
s.Frame.setSize(java.awt.Dimension(360,280));
centerfig(s.Frame);
Status = MWLabel(sprintf('Opening Property Editor...'),MWLabel.CENTER);
s.Frame.add(Status,MWBorderLayout.CENTER);
s.Frame.setVisible(1);
s.Frame.toFront;
xypos1 = s.Frame.getLocation;

%---ButtonPanel
ButtonPanel = MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,7,0));
ButtonPanel.setInsets(java.awt.Insets(2,5,5,-2));
%---Close
Close = MWButton(sprintf('Close')); ButtonPanel.add(Close);
Close.setFont(Prefs.JavaFontP);
set(Close,'ActionPerformedCallback',{@localClose,this});
%---Help
Help = MWButton(sprintf('Help')); ButtonPanel.add(Help);
Help.setFont(Prefs.JavaFontP);
set(Help,'ActionPerformedCallback',@localHelp);
%---Store handles
s.Buttons = {ButtonPanel,Close,Help};
   
%---TabPanel
s.TabPanel = MWTabPanel;
s.TabPanel.setInsets(java.awt.Insets(5,5,5,5));
s.TabPanel.setMargins(java.awt.Insets(12,8,8,8));
s.TabPanel.setFont(Prefs.JavaFontP);
this.Java = s;

% Tabs
Tabs = struct('Name',TabLabels(:),'Tab',[],'Contents',handle([]));
for ct=1:length(TabLabels)
   Tabs(ct).Tab = MWPanel(MWBorderLayout(0,0));
   s.TabPanel.addPanel(sprintf(TabLabels{ct}),Tabs(ct).Tab);
end
this.Tabs = Tabs;
   
% %---Limits tab
% this.Limits = struct('Tab',MWPanel(MWBorderLayout(0,0)),'Contents',[]);
% % s.XLimits = limit_gui(this.Data,'X');
% % s.YLimits = limit_gui(this.Data,'Y');
% % s.LimitsTab = localMakeTab(s.XLimits,s.YLimits);
% s.TabPanel.addPanel(sprintf('Limits'),this.Limits.Tab);
% 
% %---Units tab
% % s.Units = unit_gui(this.Data); 
% % s.UnitsTab = localMakeTab(s.Units);
% this.Units = struct('Tab',MWPanel(MWBorderLayout(0,0)),'Contents',[]);
% s.TabPanel.addPanel(sprintf('Units'),this.Units.Tab);
% 
% %---Style tab
% % s.Grid  = grid_gui(this.Data);
% % s.Font  = font_gui(this.Data);
% % s.Color = clr_gui(this.Data);
% this.Style = struct('Tab',MWPanel(MWBorderLayout(0,0)),'Contents',[]);
% s.TabPanel.addPanel(sprintf('Style'),this.Style.Tab);
% 
% %---Characteristics
% % s.Characteristics = char_gui(this.Data);
% % s.PhaseWrapping = wrap_gui(this.Data);
% % s.CharacteristicsTab = localMakeTab(s.Characteristics,s.PhaseWrapping);
% this.Characteristics = struct('Tab',MWPanel(MWBorderLayout(0,0)),'Contents',[]);
% s.TabPanel.addPanel(sprintf('Characteristics'),this.Characteristics.Tab);

%---Start on the first tab panel
s.TabPanel.selectPanel(0);

%---Remove the status text, add the real components and pack
s.Frame.remove(Status);
s.Frame.add(ButtonPanel,MWBorderLayout.SOUTH);
s.Frame.add(s.TabPanel,MWBorderLayout.CENTER);
% s.Frame.pack;
xypos2 = s.Frame.getLocation;
if abs(xypos1.x-xypos2.x)<5 & abs(xypos1.y-xypos2.y)<5
   centerfig(s.Frame);
end

%------------------------------------------------------
function localClose(eventSrc,eventData,h)
% Close editor
h.send('PropEditBeingClosed')
close(h)

function localHelp(varargin)
% RE: This dialog serves both CST and SRO
try
   helpview([docroot '/mapfiles/control.map'],'response_properties');
catch
   helpview([docroot '/toolbox/sloptim/sloptim.map'],'axes_properties');
end

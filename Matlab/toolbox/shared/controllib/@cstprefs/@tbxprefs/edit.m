function Frame_out = edit(h)
%EDIT  Open GUI for editing Toolbox Preferences

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:49 $

mlock

persistent Frame;

%---Abort if Java MWT is unsupported
if ~usejava('MWT')
   errordlg({...
      'Unable to open Control Toolbox Preferences GUI.';
      ' ';
      'Reason:  no Java support available on this system.'},...
      'Error');
   Frame_out = [];
   return;
end

%---Create a new editor if one is not found
if isempty(Frame)
   %---Get Toolbox Preferences
    Prefs = cstprefs.tbxprefs;
   %---Frame
    Frame = com.mathworks.mwt.MWFrame(sprintf('Control System Toolbox Preferences'));
    Frame.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
    Frame.setFont(Prefs.JavaFontP);
    set(Frame,'WindowClosingCallback',{@localCancel,Frame});
   %---Open an empty Frame with some status text
    Frame.setSize(java.awt.Dimension(360,280));
    centerfig(Frame);
    s.Status = com.mathworks.mwt.MWLabel(sprintf('Loading Toolbox Preferences...'),com.mathworks.mwt.MWLabel.CENTER);
    Frame.add(s.Status,com.mathworks.mwt.MWBorderLayout.CENTER);
    Frame.setVisible(1);
    Frame.toFront;
    xypos1 = Frame.getLocation;

   %---Handle to Toolbox Preferences
    s.OldPrefs = h;
   %---Copy of Toolbox Preferences for editing
    s.NewPrefs = copy(s.OldPrefs);
   %---Temporarily clear property values (we'll set them back after listeners are installed)
    AllProps = fieldnames(s.NewPrefs);
    for n=1:size(AllProps,1)
       set(s.NewPrefs,AllProps{n,:},'');
    end

   %---ButtonPanel
    s.ButtonPanel = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,7,0));
    s.ButtonPanel.setInsets(java.awt.Insets(2,5,5,-2));
       %---OK
        s.OK = com.mathworks.mwt.MWButton(sprintf('OK')); s.ButtonPanel.add(s.OK);
        s.OK.setFont(Prefs.JavaFontP);
        set(s.OK,'ActionPerformedCallback',{@localOK,Frame});
       %---Cancel
        s.Cancel = com.mathworks.mwt.MWButton(sprintf('Cancel')); s.ButtonPanel.add(s.Cancel);
        s.Cancel.setFont(Prefs.JavaFontP);
        set(s.Cancel,'ActionPerformedCallback',{@localCancel,Frame});
       %---Help
        s.Help = com.mathworks.mwt.MWButton(sprintf('Help')); s.ButtonPanel.add(s.Help);
        s.Help.setFont(Prefs.JavaFontP);
        set(s.Help,'ActionPerformedCallback','ctrlguihelp(''toolbox_preferences'');');

   %---TabPanel
    s.TabPanel = com.mathworks.mwt.MWTabPanel;
    s.TabPanel.setInsets(java.awt.Insets(5,5,5,5));
    s.TabPanel.setMargins(java.awt.Insets(12,8,8,8));
    s.TabPanel.setFont(Prefs.JavaFontP);
       %---Units
        s.Units = unit_gui(s.NewPrefs); 
        s.UnitsTab = localMakeTab(s.Units);
        s.TabPanel.addPanel(sprintf('Units'),s.UnitsTab);
       %---Style
        s.Grid = grid_gui(s.NewPrefs);
        s.Font = font_gui(s.NewPrefs);
        s.Color = clr_gui(s.NewPrefs);
        s.StyleTab = localMakeTab(s.Grid,s.Font,s.Color);
        s.TabPanel.addPanel(sprintf('Style'),s.StyleTab);
       %---Characteristics
        s.Characteristics = char_gui(s.NewPrefs);
        s.PhaseWrapping = wrap_gui(s.NewPrefs);
        s.CharacteristicsTab = localMakeTab(s.Characteristics,s.PhaseWrapping);
        s.TabPanel.addPanel(sprintf('Characteristics'),s.CharacteristicsTab);
       %---Siso Tool
        s.CompensatorFormat = cfmt_gui(s.NewPrefs);
        s.Bode = bode_gui(s.NewPrefs);
        s.SisoToolTab = localMakeTab(s.CompensatorFormat,s.Bode);
        s.TabPanel.addPanel(sprintf('SISO Tool'),s.SisoToolTab);
   %---Start on the first tab panel
    s.TabPanel.selectPanel(0);

   %---Store structure of handles in Frame UserData
    set(Frame,'UserData',s);

   %---Set property values (listeners will update GUI)
    for n=1:size(AllProps,1)
       set(s.NewPrefs,AllProps{n,:},s.OldPrefs.get(AllProps{n,:}));
    end

   %---Remove the status text, add the real components and pack
    Frame.remove(s.Status);
    Frame.add(s.TabPanel,com.mathworks.mwt.MWBorderLayout.CENTER);
    Frame.add(s.ButtonPanel,com.mathworks.mwt.MWBorderLayout.SOUTH);
    Frame.pack;
    xypos2 = Frame.getLocation;
    if abs(xypos1.x-xypos2.x)<5 & abs(xypos1.y-xypos2.y)<5
       centerfig(Frame);
    end

else
   %---Copy Toolbox Preferences to our editable copy
   %--- (our listeners will update the GUI automatically)
   s = get(Frame,'UserData');
   set(s.NewPrefs,get(s.OldPrefs));
   %---Raise Frame (no java methods here... findobj returns hg handles!)
   set(Frame,'Minimized','off','Visible','off','Visible','on');

end

Frame_out = Frame;


%%%%%%%%%%%%%%%%
% localMakeTab %
%%%%%%%%%%%%%%%%
function Tab = localMakeTab(varargin)
% Combine panels into a single panel for use in a tab dialog
Tab = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
for n=1:nargin
   if n<nargin
      %---Not last element, leave 5-pixel spacing
      tmp = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,5));
   else
      %---Last element, leave 0-pixel spacing
      tmp = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
   end
   %---Pack towards top
   tmp.add(varargin{n},com.mathworks.mwt.MWBorderLayout.NORTH);
   %---Add java handle to structure
   s(n,1) = tmp;
   %---Add first panel to Tab
   if n==1
      Tab.add(tmp,com.mathworks.mwt.MWBorderLayout.CENTER);
   %---Nest other panels
   else
      tmp2 = s(n-1,1);
      tmp2.add(tmp,com.mathworks.mwt.MWBorderLayout.CENTER);
   end
end
%---Store java handles
set(Tab,'UserData',s);


%%%%%%%%%%%
% localOK %
%%%%%%%%%%%
function localOK(eventSrc,eventData,Frame)
 s = get(Frame,'UserData');
 set(s.OldPrefs,get(s.NewPrefs));
 save(s.OldPrefs);
 set(Frame,'Visible','off');


%%%%%%%%%%%%%%%
% localCancel %
%%%%%%%%%%%%%%%
function localCancel(eventSrc,eventData,Frame)
 set(Frame,'Visible','off');

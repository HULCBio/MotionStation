function Main = font_gui(h)
%FONT_GUI  GUI for editing font properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:50 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Fonts'));
Main.setLayout(java.awt.GridLayout(4,1,0,3));
Main.setFont(Prefs.JavaFontB);

%---Add a font panel for each text group
s.Row1 = localFontPanel('Title',   sprintf('Titles:'),     h);  Main.add(s.Row1);
s.Row2 = localFontPanel('XYLabels',sprintf('X/Y-Labels:'), h);  Main.add(s.Row2);
s.Row3 = localFontPanel('Axes',    sprintf('Tick Labels:'),h);  Main.add(s.Row3);
s.Row4 = localFontPanel('IOLabels',sprintf('I/O-Names:'),  h);  Main.add(s.Row4);

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%%
% localFontPanel %
%%%%%%%%%%%%%%%%%%
function Panel = localFontPanel(PropName,Label,h)
% Create a java panel for editing font properties

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Build GUI
Panel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
Panel.setFont(java.awt.Font('Dialog',java.awt.Font.PLAIN,12));
s.Label = com.mathworks.mwt.MWLabel(sprintf('%s',Label),com.mathworks.mwt.MWLabel.LEFT);
   s.Label.setFont(Prefs.JavaFontP);
   Panel.add(s.Label,com.mathworks.mwt.MWBorderLayout.WEST);
s.East = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,15,0));
   Panel.add(s.East,com.mathworks.mwt.MWBorderLayout.EAST);
   s.Size = com.mathworks.mwt.MWChoice; s.East.add(s.Size);
   s.Size.setFont(Prefs.JavaFontP);
   for n=8:2:16
      s.Size.add(sprintf('%d pt',n));
   end
   s.Weight = com.mathworks.mwt.MWCheckbox(sprintf('Bold')); s.East.add(s.Weight);
      s.Weight.setFont(Prefs.JavaFontB);
   s.Angle = com.mathworks.mwt.MWCheckbox(sprintf('Italic')); s.East.add(s.Angle);
      s.Angle.setFont(Prefs.JavaFontI);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
   %---FontSize listener
    Property = [PropName 'FontSize'];
    s.SizeListener = handle.listener(h,CLS.findprop(Property),'PropertyPostSet',{@localReadProp,s.Size});
   %---FontSize callback
    set(s.Size,'Name','FontSize','ItemStateChangedCallback',{@localWriteProp,h,Property});
   %---FontWeight listener
    Property = [PropName 'FontWeight'];
    s.WeightListener = handle.listener(h,CLS.findprop(Property),'PropertyPostSet',{@localReadProp,s.Weight});
   %---FontWeight callback
    set(s.Weight,'Name','FontWeight','ItemStateChangedCallback',{@localWriteProp,h,Property});
   %---FontAngle listener
    Property = [PropName 'FontAngle'];
    s.AngleListener = handle.listener(h,CLS.findprop(Property),'PropertyPostSet',{@localReadProp,s.Angle});
   %---FontAngle callback
    set(s.Angle,'Name','FontAngle','ItemStateChangedCallback',{@localWriteProp,h,Property});

%---Store java handles
set(Panel,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,GUI)
% Update GUI when property changes
switch char(GUI.getName)
case 'FontSize'
   GUI.select((eventData.NewValue-8)/2);
case 'FontWeight'
   GUI.setState(strcmpi(eventData.NewValue,'bold'));
case 'FontAngle'
   GUI.setState(strcmpi(eventData.NewValue,'italic'));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,Property)
% Update property when GUI changes
switch get(eventSrc,'Name')
case 'FontSize'
   Value = 8 + 2*get(eventSrc,'SelectedIndex');
case 'FontWeight'
   if strcmpi(get(eventSrc,'State'),'on')
      Value = 'bold';
   else
      Value = 'normal';
   end
case 'FontAngle'
   if strcmpi(get(eventSrc,'State'),'on')
      Value = 'italic';
   else
      Value = 'normal';
   end
end
set(h,Property,Value);

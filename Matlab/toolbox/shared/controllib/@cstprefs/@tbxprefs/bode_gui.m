function Main = bode_gui(h)
%BODE_GUI  GUI for editing Siso Tool Bode options of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:44 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Bode Options'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);
   
%---Checkbox to toggle system pole/zero visibility
s.ShowSystemPZ = com.mathworks.mwt.MWCheckbox(sprintf('Show plant/sensor poles and zeros'));
s.ShowSystemPZ.setFont(Prefs.JavaFontP);
Main.add(s.ShowSystemPZ,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
s.ShowSystemPZListener = handle.listener(h,CLS.findprop('ShowSystemPZ'),'PropertyPostSet',{@localReadProp,s.ShowSystemPZ});
set(s.ShowSystemPZ,'Name','ShowSystemPZ','ItemStateChangedCallback',{@localWriteProp,h});

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,GUI)
% Update GUI when property changes
GUI.setState(strcmpi(eventData.NewValue,'on'));


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
h.ShowSystemPZ = get(eventSrc,'State');

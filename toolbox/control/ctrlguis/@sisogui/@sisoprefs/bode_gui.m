function Main = bode_gui(h)
%BODE_GUI  GUI for editing Bode options of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:07:29 $

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
s.ShowSystemPZListener = handle.listener(h,findprop(h,'ShowSystemPZ'),'PropertyPostSet',{@localReadProp,s.ShowSystemPZ});
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

function Main = grid_gui(h)
%GRID_GUI  GUI for editing grid properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:51 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Grids'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);
   
%---Checkbox to toggle grid visibility
s.Grid = com.mathworks.mwt.MWCheckbox(sprintf('Show grids by default'));
s.Grid.setFont(Prefs.JavaFontP);
Main.add(s.Grid,com.mathworks.mwt.MWBorderLayout.WEST);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
s.GridListener = handle.listener(h,CLS.findprop('Grid'),'PropertyPostSet',{@localReadProp,s.Grid});
set(s.Grid,'Name','Grid','ItemStateChangedCallback',{@localWriteProp,h});

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
h.Grid = get(eventSrc,'State');

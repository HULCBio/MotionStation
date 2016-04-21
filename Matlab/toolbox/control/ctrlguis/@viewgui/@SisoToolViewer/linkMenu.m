function linkMenu(this,MenuIndex,View)
%LINKMENU  Links Analysis menu to particular View.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/05/04 02:10:08 $

% Loacate menu
hMenu = this.Parent.HG.Menus.Analysis.PlotSelection(MenuIndex); 

% Update menu's tracking info
L = handle.listener(View,View.findprop('Visible'),'PropertyPostSet',{@LocalUncheck hMenu});
set(hMenu,'UserData',struct('View',View,'Listener',L));

%%%%%%%%%%%%%%%%%%%%
%%% LocalUncheck %%%
%%%%%%%%%%%%%%%%%%%%
function LocalUncheck(eventsrc,eventdata,hMenu)
% Uncheck plot menu when associated view goes invisible
set(hMenu,'Checked','off')
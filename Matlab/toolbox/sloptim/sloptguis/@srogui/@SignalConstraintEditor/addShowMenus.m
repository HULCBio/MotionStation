function addShowMenus(this,Parent)
% Creates Show submenus and links them to corresponding editor property.

%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:39 $
%   Copyright 1986-2004 The MathWorks, Inc.
m1 = uimenu(Parent,'Label',xlate('Initial Response'),'Check','on',...
   'Callback',@(x,y) LocalSetVis(this,'init',LocalGetVis(x)));
L = handle.listener(this,this.findprop('InitVisible'),...
   'PropertyPostSet',{@LocalUpdateCheck m1});
set(m1,'UserData',L)

m2 = uimenu(Parent,'Label',xlate('Intermediate Steps'),'Check','on',...
   'Callback',@(x,y) LocalSetVis(this,'optim',LocalGetVis(x)));
L = handle.listener(this,this.findprop('OptimVisible'),...
   'PropertyPostSet',{@LocalUpdateCheck m2});
set(m2,'UserData',L)

m3 = uimenu(Parent,'Label',xlate('Reference Signal'),'Check','on',...
   'Callback',@(x,y) LocalSetVis(this,'ref',LocalGetVis(x)));
L = handle.listener(this,this.findprop('RefVisible'),...
   'PropertyPostSet',{@LocalUpdateCheck m3});
set(m3,'UserData',L)

m4 = uimenu(Parent,'Label',xlate('Uncertainty'),'Check','on',...
   'Callback',@(x,y) LocalSetVis(this,'unc',LocalGetVis(x)));
L = handle.listener(this,this.findprop('TestVisible'),...
   'PropertyPostSet',{@LocalUpdateUncCheck m4});
set(m4,'UserData',L)

%------ Local Functions --------------------

function LocalUpdateCheck(eventsrc,eventdata,hMenu)
set(hMenu,'Check',eventdata.NewValue)

function LocalUpdateUncCheck(eventsrc,eventdata,hMenu)
Vis = eventdata.NewValue;
if length(Vis)>1
   set(hMenu,'Check',Vis{2})
end

function NewVis = LocalGetVis(hMenu)
if strcmp(get(hMenu,'Check'),'on')
   NewVis = 'off';
else
   NewVis = 'on';
end

function LocalSetVis(this,PlotType,Vis)
% Sets plot visibility
switch PlotType
   case 'init'
      this.InitVisible = Vis;
   case 'optim'
      this.OptimVisible = Vis;
   case 'ref'
      this.RefVisible = Vis;
   case 'unc'
      if length(this.TestVisible)>1
         this.TestVisible(2,1) = {Vis};
      end
end


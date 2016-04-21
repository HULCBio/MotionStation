function c=attribute(c,action,varargin)
%ATTRIBUTE run component GUI in setup file editor

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:12 $



switch lower(action)
case 'start'
   c=LocStartGUI(c);
case 'updatecomp'
   c=LocUpdateComp(c);
case 'resize'
   c=LocResize(c);
otherwise
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocStartGUI(c)

info=getinfo(c);

c.x.sourcetype=uicontrol(c.x.all,...
   'style','text',...
   'horizontalalignment','left');
c.x.sourceedit=uicontrol(c.x.all,...
   'style','edit',...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left',...
   'Callback',[c.x.getobj,'''updatecomp'');'],...   
   'String',c.att.headertext);

c.x.weighttext=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Header Size');

a=getattx(c,'weight');
index=find(strcmp(a.enumValues,c.att.weight));
if length(index)>0
   index=index(1);
else
   index=1;
end

c.x.weightpop=uicontrol(c.x.all,...
   'style','popupmenu',...
   'Callback',[c.x.getobj,'''updatecomp'');'],...   
   'BackgroundColor',[1 1 1],...
   'Value',index,...
   'UserData',a.enumValues,...
   'String',a.enumNames);

%c.x.aligntext=uicontrol(c.x.all,...
%   'style','text',...
%   'HorizontalAlignment','left',...
%   'String','Justification');
%a=getattx(c,'align');
%c.x.alignpop=uicontrol(c.x.all,...
%   'style','popupmenu',...
%   'Callback',[c.x.getobj,'''updatecomp'');'],...   
%   'BackgroundColor',[1 1 1],...
%   'UserData',a.enumValues,...
%   'String',a.enumNames); 
%index=findinlist(c,a.enumValues,c.att.align);
%if index>0
%   set(c.x.alignpop,'value',index);
%else
%   set(c.x.alignpop,'value',1);
%end

c.x.exdtext=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'String','Header Preview');
c.x.exframe=uicontrol(c.x.all,...
   'style','frame',...
   'BackgroundColor',[1 1 1]);
c.x.exhtext=uicontrol(c.x.all,...
   'BackgroundColor',[1 1 1],...
   'style','text');

c=LocResize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function c=LocResize(c)

barht=15;
pad=10;
tabwidth=c.x.xext-c.x.xzero;

pos=[c.x.xzero+pad c.x.ylim-barht tabwidth-2*pad barht];
set(c.x.sourcetype,'Position',pos);

pos=[c.x.xzero+3*pad pos(2)-barht tabwidth-5*pad barht];
set(c.x.sourceedit,'Position',pos);

descwidth=60;
popwidth=100;

pos=[c.x.xzero+pad pos(2)-2*barht descwidth barht];
set(c.x.weighttext,'Position',pos);

pos=[pos(1)+pos(3) pos(2) popwidth barht];
set(c.x.weightpop,'Position',pos);

%pos=[c.x.xzero+pad pos(2)-barht descwidth barht];
%set(c.x.aligntext,'Position',pos);

%pos=[pos(1)+pos(3) pos(2) popwidth barht];
%set(c.x.alignpop,'Position',pos);

pos=[c.x.xzero+pad pos(2)-2*barht descwidth barht];
set(c.x.exdtext,'Position',pos);

frameht=5*barht;
pos=[c.x.xzero+2*pad pos(2)-frameht tabwidth-4*pad frameht];
set(c.x.exframe,'Position',pos);

texht=3*barht;

pos=[c.x.xzero+3*pad pos(2)+(frameht-texht)/2 tabwidth-6*pad texht];
set(c.x.exhtext,'Position',pos);

c=LocUpdateComp(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function c=LocUpdateComp(c)

c.att.headertext=get(c.x.sourceedit,'String');
if numsubcomps(c)==0
   %we are drawing our header from the local string
   set(c.x.sourcetype,'String','Header text determined from string:');
   set(c.x.sourceedit,'Enable','on');
   set(c.x.exhtext,'String',c.att.headertext);
else
   %we are drawing our header from subcomponents
   set(c.x.sourcetype,'String','Header text determined from subcomponents');
   set(c.x.sourceedit,'Enable','off');
   set(c.x.exhtext,'String','An Example Header');
end

weightindex=get(c.x.weightpop,'Value');
weightvalues=get(c.x.weightpop,'UserData');
c.att.weight=weightvalues{weightindex};

%alignindex=get(c.x.alignpop,'Value');
%alignvalues=get(c.x.alignpop,'UserData');
%c.att.align=alignvalues{alignindex};

basesize=get(c.x.sourcetype,'Fontsize');
fontpoints=floor(basesize*[2.5 2.5 2 1.5 1 .5]);
set(c.x.exhtext,...
   'FontSize',fontpoints(weightindex),...
   'HorizontalAlignment','left');
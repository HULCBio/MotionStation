function c=embedattribute(c,action,varargin)
%EMBEDATTRIBUTES embeds attributes page into a modal figure window

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:58 $

switch action
case 'start'
   c=feval('start',c,varargin{:});
case 'Resume'
   c=subsasgn(c,substruct('.','x','.','resumeAction'),varargin{1});
   h=subsref(c,substruct('.','x','.','ModalFigure'));
   set(h,'UserData',c);
   uiresume(h);
otherwise
   attMethod=subsref(c,substruct('.','x','.','attMethod'));
   c=feval(attMethod,c,action,varargin{:});
   h=subsref(c,substruct('.','x','.','ModalFigure'));
   set(h,'UserData',c);
end

   
%--------1---------2---------3---------4---------5---------6---------7---------8
function c=start(c,attMethod,compTitle)

if nargin<3
   i=getinfo(c);
   compTitle=i.Name;
   if nargin<2
      attMethod='attribute';
   end
end

oldC=c;

c=LocModalizeComponent(c,'embedattribute');

c=feval(attMethod,c,'start');

x=subsref(c,substruct('.','x'));

x.attMethod=attMethod;

x.OkButton= uicontrol(x.all,...
   'Style','pushbutton',...
   'Callback',[x.getobj,'''Resume'',''OK'');'],...
   'String','    OK    ');

x.CancelButton= uicontrol(x.all,...
   'Style','pushbutton',...
   'Callback',[x.getobj,'''Resume'',''Cancel'');'],...
   'String','Cancel');

x.ComponentHelpButton = uicontrol(x.all,...
   'style','pushbutton',...
   'String','  Help  ',...
   'Callback',...
   sprintf('helpview(rptparent,''%s'',''component'');',class(c)));

x.statusbar = uicontrol(x.all,...
   'style','edit',...
   'Enable','inactive',...
   'HorizontalAlignment','left');

if ~isempty(compTitle)
   x.title=uicontrol(x.all,...
      'style','text',...
      'FontSize',get(0,'defaultuicontrolfontsize')*2-1,...
      'HorizontalAlignment','left',... 
      'String',compTitle);
end

x.LayoutManager={
   [5]
   x.title
   x.LayoutManager
   [5]
   {x.ComponentHelpButton [inf 5] x.OkButton [5] x.CancelButton}
   [5]
   x.statusbar
};

c=subsasgn(c,substruct('.','x'),x);
c=controlsresize(c);
x=subsref(c,substruct('.','x'));

yTrans=x.lowLimit-5;

%translate everything down
figPos=get(x.all.Parent,'Position');
figChildren=allchild(x.all.Parent);
objPos=get(figChildren,'Position');
objPos=cat(1,objPos{:});
objPos(:,2)=objPos(:,2)-yTrans;
objPos=num2cell(objPos,2);
set(figChildren,{'Position'},objPos);

figPos(4)=figPos(4)-yTrans;

figH=x.ModalFigure;

set(figH,'UserData',c,...
   'Visible','on',...
   'Position',figPos);
uiwait(figH);

c=get(figH,'UserData');

switch subsref(c,substruct('.','x','.','resumeAction'))
case 'OK'
   oldC=subsasgn(oldC,substruct('.','att'),...
      subsref(c,substruct('.','att')));
   c=oldC;   
otherwise %'cancel'
   c=oldC;
end

delete(figH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=onoff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocModalizeComponent(c,dialogName);
%This function alters C so that it can be
%used with the present modal dialog instead
%of its usual attribute page

x=subsref(c,substruct('.','x'));

x.InvisibleHandles=[];
x.ComponentPointer=struct('Area',{},'Pointer',{});
x.all=struct('Units','Points',...
   'Visible','on',...
   'Tag',[dialogName 'Object'],...
   'HandleVisibility','off',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
x.getobj=[dialogName '(get(gcbf,''UserData''),'];
x.title=[];
x.ComponentHelpButton=[];
x.statusbar=[];

Xlim=300;
Ylim=500;

x.xzero = 0;
x.xext  = Xlim;
x.xlim  = Xlim;
x.ylim  = Ylim;
x.yorig = 0;
x.yzero = 0;

sfeHandle=findobj(allchild(0),'flat','Tag','Setup File Editor');

if length(sfeHandle)>0
   sfePos=get(sfeHandle(1),'Position');
   figXzero=sfePos(1)+50;
   figYzero=sfePos(2)+50;   
else
   figXzero=300;
   figYzero=300;
end

x.ModalFigure = figure('DoubleBuffer','on',...
   'Units',x.all.Units,...
   'HandleVisibility',x.all.HandleVisibility,...
   'IntegerHandle','off',...
   'MenuBar','none', ...
   'Color',x.all.BackgroundColor,...
   'Name','Edit Component Options', ...
   'Tag','RpTgEn EmBeDdEd CoMpOnEnT',...
   'Visible','off',...
   'Position',[figXzero figYzero Xlim Ylim],...
   'NumberTitle','off', ... 
   'WindowStyle','modal',...
   'CloseRequestFcn',[x.getobj,'''Resume'',''Cancel'');'],...
   'resize','off');

x.all.Parent=x.ModalFigure;

c=subsasgn(c,substruct('.','x'),x);


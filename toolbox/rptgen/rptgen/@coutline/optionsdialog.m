function c=optionsdialog(c,action,varargin)
%OPTIONSDIALOG runs the "generation options" modal dialog

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:26 $

switch action
case 'start'
   c=feval(action,c,varargin{:});
otherwise
   c=feval(action,c,varargin{:});
   set(c.x.ModalFigure,'UserData',c);
end

   
%--------1---------2---------3---------4---------5---------6---------7---------8
function c=start(c)

iconCdata=c.x.cdata;
oldC=c;

c=LocModalizeComponent(c,'optionsdialog');

genFrame=controlsframe(c,'Generation options');

%make all of the other controls

controlList={'isView','isRegenerateImages','isAutoSaveOnGenerate'};

c=controlsmake(c,controlList);

for i=1:length(controlList)
   currVal=getfield(c.att,controlList{i});
   currUserData=getfield(iconCdata,controlList{i});
   if currVal
      currCdata=currUserData.ok;
   else
      currCdata=currUserData.no;
   end
   currH=uicontrol(c.x.all,...
      'style','togglebutton',...
      'value',1,...
      'enable','off',...
      'Cdata',currCdata,...
      'UserData',currUserData);
   c.x=setfield(c.x,[controlList{i} 'Toggle'],currH);   
end



c.x.OkButton= uicontrol(c.x.all,...
   'Style','pushbutton',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'),...
   'Callback',[c.x.getobj,'''Resume'',''OK'');'],...
   'String','    OK    ');

c.x.CancelButton= uicontrol(c.x.all,...
   'Style','pushbutton',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'),...
   'Callback',[c.x.getobj,'''Resume'',''Cancel'');'],...
   'String','Cancel');

genFrame.FrameContent={
   c.x.isAutoSaveOnGenerateToggle [3] c.x.isAutoSaveOnGenerate
   [3] [3] [3]
   c.x.isViewToggle [3] c.x.isView
   [3] [3] [3]
   c.x.isRegenerateImagesToggle [3] c.x.isRegenerateImages
   [3] [3] [3]};

c.x.LayoutManager={[5]
   genFrame
   [5]
   {[inf 5] c.x.OkButton [5] c.x.CancelButton}};

c=controlsresize(c);


yTrans=c.x.lowLimit-5;

%translate everything down
figPos=get(c.x.all.Parent,'Position');
figChildren=allchild(c.x.all.Parent);
objPos=get(figChildren,'Position');
objPos=cat(1,objPos{:});
objPos(:,2)=objPos(:,2)-yTrans;
objPos=num2cell(objPos,2);
set(figChildren,{'Position'},objPos);

figPos(4)=figPos(4)-yTrans;




figH=c.x.ModalFigure;
set(figH,'UserData',c,...
   'Visible','on',...
   'Position',figPos);
uiwait(figH);
c=get(figH,'UserData');

switch c.x.resumeAction
case 'OK'
   oldC.att=c.att;
   c=oldC;   
otherwise %'cancel'
   c=oldC;
end
delete(figH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Resume(c,resumeAction)

c.x.resumeAction=resumeAction;
uiresume(c.x.ModalFigure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});


currH=getfield(c.x,[whichControl 'Toggle']);
currUserData=get(currH,'UserData');
currVal=getfield(c.att,whichControl);

if currVal
   currCdata=currUserData.ok;
else
   currCdata=currUserData.no;
end

set(currH,'CData',currCdata);




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

x.all=struct('Units','Points',...
   'Visible','on',...
   'Tag',[dialogName 'Object'],...
   'HandleVisibility','off',...
   'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));

Xlim=300;
Ylim=500;

x.getobj= [dialogName '(get(gcbf,''UserData''),'];

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
   'Units',c.x.all.Units,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'IntegerHandle','off',...
   'MenuBar','none', ...
   'Color',c.x.all.BackgroundColor,...
   'Name','Edit Generation Options', ...
   'Tag','RpTgEn CoUtLiNe GeNeRaTiOn OpTiOnS',...
   'Visible','off',...
   'Position',[figXzero figYzero Xlim Ylim],...
   'NumberTitle','off', ... 
   'WindowStyle','modal',...
   'CloseRequestFcn',[x.getobj,'''Resume'',''Cancel'');'],...
   'resize','off');

x.all.Parent=x.ModalFigure;

c.x=x;
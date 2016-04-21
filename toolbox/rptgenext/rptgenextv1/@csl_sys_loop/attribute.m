function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:44 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Report On ');
sortFrame=controlsframe(c,'Sort Systems ');

c=controlsmake(c);

slCD=getslcdata(c);
loopInfo=loopsystem(c.zslmethods);

c.x.LoopData=[loopInfo.contextCode,...
      {slCD.SystemLarge;slCD.ModelLarge;...
         slCD.SignalLarge;slCD.BlockLarge;slCD.ModelLarge},...
      loopInfo.contextName];

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'Position',[-100 -100 1 1]);

loopFrame.FrameContent={
   c.x.LoopType(1)
   c.x.LoopType(2)
   {'indent' c.x.ObjectList}  %[1] c.x.isSortList}
};

sortFrame.FrameContent=num2cell(c.x.SortBy');

c.x.LayoutManager={loopFrame
   [5]
   sortFrame};

UpdateFrame(c);
EnableControls(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

UpdateFrame(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});
EnableControls(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EnableControls(c);

%set([c.x.ObjectList,c.x.isSortList],'enable',...
%   onoff(strcmp(c.att.LoopType,'$list')));

%set(c.x.SortBy,'enable',...
%   onoff(strcmp(c.att.LoopType,'$auto') | c.att.isSortList));

set([c.x.ObjectList],'enable',...
   onoff(strcmp(c.att.LoopType,'$list')));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFrame(c);

lType=getparentloop(c);
ud=c.x.LoopData;

typeIndex=find(strcmp(ud(:,1),lType));
if length(typeIndex)<1
   typeIndex=size(ud,1);
else
   typeIndex=typeIndex(1);
end

set(c.x.LoopImage,'CData',ud{typeIndex,2});
set(c.x.LoopType(1),'String',...
   sprintf('Auto - %s',ud{typeIndex,3}));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


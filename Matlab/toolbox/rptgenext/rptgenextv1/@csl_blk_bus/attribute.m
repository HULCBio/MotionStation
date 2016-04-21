function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:11 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

blocksFrame=controlsframe(c,'Show Bus Blocks ');
contentFrame=controlsframe(c,'List Options');

c=controlsmake(c);

slCD=getslcdata(c);
liUD={'Model' slCD.ModelLarge 'All bus blocks in current model'
   'System' slCD.SystemLarge 'All bus blocks in current system'
   'Signal' slCD.SignalLarge 'All bus blocks connected to current signal'
   'Block' slCD.BlockLarge 'Current block if it is a bus block'
   '' slCD.ModelLarge 'All bus blocks in all models'};

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'UserData',liUD);

c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'HorizontalAlignment','left');


blocksFrame.FrameContent={c.x.LoopImage [5] {c.x.LoopEcho;...
         c.x.isHierarchy}};

contentFrame.FrameContent={
    {c.x.ListTitleTitle c.x.ListTitle}
    [5]
    c.x.BusAnchor
    c.x.SignalAnchor
};

c.x.LayoutManager={blocksFrame
   [5]
   contentFrame};

UpdateFrame(c);

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

UpdateFrame(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFrame(c);

lType=getparentloop(c);
ud=get(c.x.LoopImage,'UserData');

typeIndex=find(strcmp(ud(:,1),lType));
if length(typeIndex)<1
   typeIndex=1;
else
   typeIndex=typeIndex(1);
end

set(c.x.LoopImage,'CData',ud{typeIndex,2});
set(c.x.LoopEcho,'String',ud{typeIndex,3});

statbar(c,sprintf('Bus Block List - %s', ud{typeIndex,3}),...
   strncmpi(ud{typeIndex,3},xlate('Warning'),7));

   
function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:18 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

frameHelp=controlsframe(c,'Extract Text From');
frameCont=controlsframe(c,'Text Format');

c=controlsmake(c);

slCD=getslcdata(c);
liUD={'Model' slCD.ModelLarge 'All doc blocks in current model'
   'System' slCD.SystemLarge 'All doc blocks in current system'
   'Signal' slCD.SignalLarge 'Can not run in signal loop'
   'Block' slCD.BlockLarge 'Current block if it is a doc block'
   '' slCD.ModelLarge 'All doc blocks in all models'};

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'UserData',liUD);

c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'HorizontalAlignment','left');

frameHelp.FrameContent={c.x.LoopImage,5,{c.x.LoopEcho;[150 1]}};

frameCont.FrameContent={
    c.x.LinkingAnchor
    [5]
    {c.x.ImportTypeTitle (num2cell(c.x.ImportType'))}
};

c.x.LayoutManager={
    [2]
    frameHelp
    [2]
    frameCont
};

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
UpdateFrame(c);

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

statbar(c,sprintf('Doc Block - %s', ud{typeIndex,3}),...
   strncmpi(ud{typeIndex,3},xlate('Warning'),7));

   

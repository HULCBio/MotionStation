function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:07 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

blocksFrame=controlsframe(c,'Count Block Types ');
contentFrame=controlsframe(c,'Table Content ');

c=controlsmake(c);

slCD=getslcdata(c);
liUD={'Model' slCD.ModelLarge 'In current model: '
   'System' slCD.SystemLarge 'In current system'
   'Signal' slCD.SignalLarge 'Warning - "Block Count" can not be a child of "Signal Loop"'
   'Block' slCD.BlockLarge 'Warning - "Block Count" can not be a child of "Block Loop"'
   '' slCD.ModelLarge 'All blocks in all models'};

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'UserData',liUD);

c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'HorizontalAlignment','left');


blocksFrame.FrameContent={c.x.LoopImage [5] {c.x.LoopEcho;...
         {'indent' num2cell(c.x.IncludeBlocks')}}};

contentFrame.FrameContent={[3]
   {c.x.TableTitleTitle c.x.TableTitle}
   [5]
   c.x.isBlockName
   [5]
   {c.x.SortOrderTitle num2cell(c.x.SortOrder')}};

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

if strcmp(lType,'Model')
   set(c.x.IncludeBlocks,'Enable','on');
else
   set(c.x.IncludeBlocks,'Enable','off');
end

statbar(c,sprintf('Count block types - %s', ud{typeIndex,3}),...
   strncmpi(ud{typeIndex,3},xlate('Warning'),7));

   
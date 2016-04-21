function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:21 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Report on ');
sortFrame=controlsframe(c,'Sort Signals');

%c.x=LocDrawPreviewPicture(c.x);

c=controlsmake(c);

slCD=getslcdata(c);
loopInfo=loopsignal(c.zslmethods);
liUD=[loopInfo.contextCode,...
      {slCD.SystemLarge;slCD.ModelLarge;...
         slCD.SignalLarge;slCD.BlockLarge;slCD.ModelLarge},...
      loopInfo.contextName];

c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'UserData',liUD);

c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'HorizontalAlignment','left');

contextRow={c.x.LoopImage [3] c.x.LoopEcho;[1] [1] [inf 1]};
if logical(0)
   %hide the incoming/outgoing options
   loopFrame.FrameContent=contextRow;
   set([c.x.isBlockIncoming,c.x.isBlockOutgoing,c.x.isSystemIncoming,...
         c.x.isSystemOutgoing,c.x.isSystemInternal c.x.previewAxis],...
      'Position',[10000 -10000 2 2]);
else
   optionsColumn={'indent',{c.x.isBlockIncoming;c.x.isBlockOutgoing},...
      {c.x.isSystemIncoming;c.x.isSystemOutgoing;c.x.isSystemInternal}};
   
   loopFrame.FrameContent={
      contextRow
      [5]
      optionsColumn
   };
end


sortFrame.FrameContent=num2cell(c.x.SortBy');
c.x.LayoutManager={loopFrame
   [5]
   sortFrame};

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
errMsg='';
switch whichControl
case {'isBlockIncoming' 'isBlockOutgoing'}
   if ~any([c.att.isBlockIncoming c.att.isBlockOutgoing])
      c.att=setfield(c.att,whichControl,logical(1));
      set(getfield(c.x,whichControl),'Value',logical(1));
      errMsg='At least one block signal type must be selected';
   else
      LocRedrawPreview(c);
   end
case {'isSystemIncoming' 'isSystemOutgoing' 'isSystemInternal'}
   if ~any([c.att.isSystemIncoming,...
            c.att.isSystemOutgoing,...
            c.att.isSystemInternal])
      c.att=setfield(c.att,whichControl,logical(1));
      set(getfield(c.x,whichControl),'Value',logical(1));
      errMsg='At least one system signal type must be selected';
   else
      LocRedrawPreview(c);
   end
end

statbar(c,errMsg,logical(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateFrame(c);

lType=getparentloop(c);
ud=get(c.x.LoopImage,'UserData');

typeIndex=find(strcmp(ud(:,1),lType));
if length(typeIndex)<1
   typeIndex=size(ud,1);
else
   typeIndex=typeIndex(1);
end

set(c.x.LoopImage,'CData',ud{typeIndex,2});
set(c.x.LoopEcho,'String',ud{typeIndex,3});

blockHandles=[c.x.isBlockIncoming c.x.isBlockOutgoing];
systemHandles=[c.x.isSystemIncoming c.x.isSystemOutgoing c.x.isSystemInternal];

switch lType
case 'System'
   set(systemHandles,'Enable','on');
   set(blockHandles,'Enable','off');
case 'Block'
   set(blockHandles,'Enable','on');
   set(systemHandles,'Enable','off');
case ''
   set([systemHandles blockHandles],'Enable','on');
otherwise
   set([systemHandles blockHandles],'Enable','off');
end

%LocRedrawPreview(c,lType);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x=LocDrawPreviewPicture(x);

childProp=struct('Parent',x.all.Parent,...
   'Units',x.all.Units,...
   'Tag',x.all.Tag,...
   'HandleVisibility',x.all.HandleVisibility,...
   'Visible',x.all.Visible);

x.previewAxis=axes(childProp,...
   'Box', 'on',...
   'Color', 'none',...
   'Xcolor',[0 0 0],...
   'Ycolor',[0 0 0],...
   'Xlim',[0 1],...
   'Ylim',[0 1],...
   'XTick',[],...
   'YTick',[],...
   'ZTick',[],...
   'visible','off');

childProp.Parent=x.previewAxis;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocRedrawPreview(c,currContext);

if nargin<2
   currContext=getparentloop(c);
end



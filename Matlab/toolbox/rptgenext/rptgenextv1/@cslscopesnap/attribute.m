function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:35 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

loopFrame=controlsframe(c,'Take Snapshots of ');
optFrame=controlsframe(c,'Snapshot Options ');

c=controlsmake(c);

cString=[num2str(c.att.PaperSize(1)) 'x' ...
      num2str(c.att.PaperSize(2))];
set(c.x.PaperSize,'String',cString);


slCD=getslcdata(c);

loopInfo=searchblocktype(c.zslmethods,sprintf('XY graphs & scope'));
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


loopFrame.FrameContent={c.x.LoopImage [3] {c.x.LoopEcho;...
         [inf 1];...
         num2cell(c.x.isForceOpen')}};
optFrame.FrameContent={
   {c.x.ImageFormatTitle c.x.ImageFormat
      [3] [3]
      c.x.PaperSizeTitle {c.x.PaperSize c.x.PaperUnits}
      [3] [3]
      c.x.PaperOrientationTitle num2cell(c.x.PaperOrientation')
      [3] [3]
      c.x.CaptionTypeTitle {
         c.x.CaptionType(1)
         c.x.CaptionType(2)
      }
   }
   [3]
   c.x.isInvertHardcopy
   c.x.AutoscaleScope};

c.x.LayoutManager={loopFrame
   [5]
   optFrame};

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

switch whichControl
case 'PaperSize'
   [c.att.PaperSize,errMsg]=rptgenutil('str2numNxN',...
      c.x.PaperSize,c.att.PaperSize);
   statbar(c,errMsg,~isempty(errMsg));
case 'PaperUnits'
   oldUnits=c.att.PaperUnits;
   c=controlsupdate(c,whichControl,varargin{:});
   newUnits=c.att.PaperUnits;
   c.att.PaperSize=rptgenutil('SizeUnitTransform',...
      c.att.PaperSize,...
      oldUnits,...
      newUnits,...
      c.x.PaperSize);
otherwise
   c=controlsupdate(c,whichControl,varargin{:});   
end

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

descString=ud{typeIndex,3};

set(c.x.LoopImage,'CData',ud{typeIndex,2});
set(c.x.LoopEcho,'String',descString);

statbar(c,sprintf('Take snapshots of - %s', descString),...
   strncmpi(descString,xlate('Warning'),7));

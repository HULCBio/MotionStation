function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:04 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

refFrame=controlsframe(c,'Starting System');
dispFrame=controlsframe(c,'Display Systems');
styleFrame = controlsframe(c,'List Style');

c=controlsmake(c);

refFrame.FrameContent={
   [3]
   {c.x.StartSysTitle num2cell(c.x.StartSys') };
   c.x.HighlightStartSys
};
dispFrame.FrameContent={
   {
      c.x.ParentDepthTitle c.x.ParentDepth
      c.x.ChildDepthTitle c.x.ChildDepth
   }
   c.x.isPeers
};

styleFrame.FrameContent={
	num2cell(c.x.DisplayAs')   
   };


c.x.LayoutManager={refFrame
   [5]
   dispFrame
   [5]
	styleFrame};

%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

c=resize(c);

set([c.x.isPeers c.x.ParentDepth],'Enable',...
   LocOnOff(strcmp(c.x.StartSys,'TOP')))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'StartSys'
   set([c.x.isPeers c.x.ParentDepth],'Enable',...
      LocOnOff(~strcmp(c.att.StartSys,'TOP')))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

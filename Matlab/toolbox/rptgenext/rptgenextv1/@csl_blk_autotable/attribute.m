function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:04 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

tableFrame = controlsframe(c,'Table Properties');
contentFrame = controlsframe(c,'Table Content');
c=controlsmake(c);

titleOpts= {
   c.x.TitleType(1);
   c.x.TitleType(2);
   {c.x.TitleType(3) c.x.TitleString}
};

tableFrame.FrameContent = {
   {c.x.TitleTypeTitle titleOpts} 
   c.x.isBorder
};

contentFrame.FrameContent={
   {c.x.HeaderTypeTitle num2cell(c.x.HeaderType)'}
      c.x.isNamePrompt
   };


c.x.LayoutManager={contentFrame;[5];tableFrame};

c=resize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


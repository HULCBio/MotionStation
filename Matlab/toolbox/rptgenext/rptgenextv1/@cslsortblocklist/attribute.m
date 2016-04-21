function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:58 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

displayFrame=controlsframe(c,'Display Options');
contentFrame=controlsframe(c,'Report Options');

c=controlsmake(c);
ChangeListTitleTitle(c);

contentFrame.FrameContent={...
      {c.x.LinkToTitle num2cell(c.x.LinkTo')}
   c.x.isBlockType};

displayFrame.FrameContent={...
      c.x.RenderAsTitle num2cell(c.x.RenderAs')
   c.x.ListTitleTitle c.x.ListTitle};

c.x.LayoutManager={contentFrame
   [5]
   displayFrame};


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});
switch whichControl
case 'RenderAs'
   ChangeListTitleTitle(c);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeListTitleTitle(c)

if strcmp(c.att.RenderAs,'cfrlist')
   tString='   List title ';
else
   tString='Table title ';
end

set(c.x.ListTitleTitle,'String',tString);

function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:49 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

textFrame=controlsframe(c,'Comment Text');
dispFrame=controlsframe(c,'Status Message');

c=controlsmake(c);


textFrame.FrameContent={c.x.CommentText};

dispFrame.FrameContent={
   c.x.isDisplayComment
   [2]
   {c.x.CommentStatusLevelTitle c.x.CommentStatusLevel}
};


c.x.LayoutManager={[5]
   textFrame
   5
   dispFrame
};


c=refresh(c);
c=resize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%status message level can not be active if
%not inserting a status message into the report.

set([c.x.CommentStatusLevelTitle c.x.CommentStatusLevel],...
   'Enable',onoff(c.att.isDisplayComment));



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

c=refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


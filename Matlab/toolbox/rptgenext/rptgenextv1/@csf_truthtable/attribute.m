function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
   %C=ATTRIBUTE(C,'start') is called when the page is drawn
   %C=ATTRIBUTE(C,'resize') is called when the page is resized

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:43 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%controlsframe creates a nice-looking border
%which can surround UICONTROLS.  Controlsframe
%must be run before controlsmake in order to get
%the stacking order right.  A frame requires the
%use of a custom c.x.LayoutManager.

%frameHandle=controlsframe(c,'Frame Title');

%controlsmake creates the UICONTROLS.
%they are passed back in c.x with fieldnames
%mirroring the attribute name.  For example,
%c.att.Foo creates a uicontrol with handle
%c.x.Foo.  If the control creates a text field
%(for example a compound text/edit) the text
%field's handle is c.x.FooTitle

%controlsmake uses getinfo(c) to obtain the information
%it needs to automatically create uicontrols.  
%Information is stored in c.attx.Foo

c=controlsmake(c);

conditionFrame=controlsframe(c,'Condition Table');
conditionFrame.FrameContent = {
	c.x.ShowConditionHeader
	c.x.ShowConditionNumber
	c.x.ShowConditionDescription
	c.x.ShowConditionCode
    {c.x.ConditionWrapLimitTitle c.x.ConditionWrapLimit}
};

actionFrame=controlsframe(c,'Action Table');
actionFrame.FrameContent = {
	c.x.ShowActionHeader
	c.x.ShowActionNumber
	c.x.ShowActionDescription
	c.x.ShowActionCode
};


c.x.LayoutManager = {{c.x.TitleModeTitle,{
        c.x.TitleMode(1)
        c.x.TitleMode(2)
        {c.x.TitleMode(3),c.x.Title};
    }} %c.x.FixedWidthCode
    [5]
	conditionFrame
	[5]
	actionFrame
};

c=refresh(c);
c=resize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c)

if strcmp(c.att.TitleMode,'manual')
    set(c.x.Title,'enable','on');
else
    set(c.x.Title,'enable','off');
end

%refresh is called anytime a "start" would
%be called but the page is already active
%Example: moving, deactivating, select outline

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


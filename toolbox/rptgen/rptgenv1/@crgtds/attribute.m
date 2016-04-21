function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:29 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

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

timeFrame=controlsframe(c,'Time Stamp Properties');
dateFrame=controlsframe(c,'Date Stamp Properties');
previewFrame=controlsframe(c,'Stamp Preview');

c=controlsmake(c);

c.x.previewText=uicontrol(c.x.all,...
   'Style','text',...
   'String','',...
   'BackgroundColor',[1 1 1],...
   'Fontsize',14);

timeFrame.FrameContent={c.x.istime
   {c.x.timesepTitle c.x.timesep c.x.timeformatTitle c.x.timeformat}
   c.x.timesec};


dateFrame.FrameContent={c.x.isdate
   {c.x.dateorderTitle c.x.dateorder c.x.datemonthTitle c.x.datemonth
      c.x.datesepTitle c.x.datesep c.x.dateyearTitle c.x.dateyear}};

previewFrame.FrameContent={c.x.previewText};

c.x.LayoutManager={{c.x.isprefix c.x.prefixstring}
   [5]
   timeFrame
   [5]
   dateFrame
   [5]
   previewFrame};

%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

LocRedraw(c);

c=resize(c);

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

LocRedraw(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocRedraw(c)

set(c.x.prefixstring,'enable',...
   LocOnOff(c.att.isprefix));
set([c.x.dateorder,c.x.datesep,c.x.datemonth,c.x.dateyear],'enable',...
   LocOnOff(c.att.isdate));
set([c.x.timeformat,c.x.timesep,c.x.timesec],'enable',...
   LocOnOff(c.att.istime));

set(c.x.previewText,'String',execute(c));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:39 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)


titleFrame=controlsframe(c,'Title Options');
mainFrame=controlsframe(c,'Paragraph Text');

c=controlsmake(c);

titleFrame.FrameContent={
   c.x.TitleType(1)
   c.x.TitleType(2)
   {c.x.TitleType(3) c.x.ParaTitle}
};

mainFrame.FrameContent={c.x.ParaText};


c.x.LayoutManager={titleFrame
   [5]
   mainFrame};

c=refresh(c);
c=resize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

numChild=numsubcomps(c);

errMsg='';
switch c.att.TitleType
case 'specify'
   titleEnable='on';
   minSubcomps=0;
   titleString='';
case 'subcomp'
   titleEnable='off';
   minSubcomps=1;
   titleString='  Paragraph title will be drawn from first child';
   if numChild<1
      errMsg='Warning - no first child component';
   end
otherwise
   titleEnable='off';
   minSubcomps=0;
   titleString='';
end
statbar(c,errMsg,1);

set(c.x.ParaTitle,'enable',titleEnable);

if numChild > minSubcomps
   paraString={
      'PARAGRAPH has subcomponents - '
      '  Paragraph text will be drawn from children'
      ''
      titleString
   };
   paraEnable='off';
else
   paraString=c.att.ParaText;
   paraEnable='on';
end
set(c.x.ParaText,...
   'String',paraString,...
   'Enable',paraEnable);

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


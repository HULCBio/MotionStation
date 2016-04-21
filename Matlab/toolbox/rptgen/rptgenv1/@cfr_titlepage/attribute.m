function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:58 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%nameFrame=controlsframe(c,'Main Information');

c=controlsmake(c);
%set([c.x.AbstractTitle c.x.Legal_NoticeTitle ...
%     c.x.AuthorHonorificTitle   c.x.AuthorFirstNameTitle ...
%     c.x.AuthorSurnameTitle ],'HorizontalAlignment','left');

set(c.x.DateFormat,'ToolTipString','Date format');

set([c.x.AbstractTitle c.x.Legal_NoticeTitle], ...
    'HorizontalAlignment','left');

set([c.x.Copyright_Date     ,c.x.Copyright_Holder, ...
     c.x.Copyright_DateTitle,c.x.Copyright_HolderTitle], ...
      'enable',onoff(c.att.Include_Copyright));

set(c.x.DateFormat,'enable',onoff(c.att.Include_Date));

%nameFrame.FrameContent={
%  {c.x.TitleTitle    c.x.Title [0]
%  c.x.SubtitleTitle c.x.Subtitle [0]}
%  c.x.AuthorHonorificTitle   c.x.AuthorFirstNameTitle c.x.AuthorSurnameTitle
%  c.x.AuthorHonorific        c.x.AuthorFirstName      c.x.AuthorSurname
%  };

c.x.LayoutManager={
  {c.x.TitleTitle    c.x.Title
     c.x.SubtitleTitle c.x.Subtitle
     c.x.ImageTitle num2cell(c.x.Image)
  [4] [4] 
  c.x.AuthorTitle c.x.Author}
  [4]
  {c.x.Include_Date c.x.DateFormat}
  [4]
  {c.x.Include_Copyright  'spacer'
   c.x.Copyright_HolderTitle c.x.Copyright_Holder
   c.x.Copyright_DateTitle   c.x.Copyright_Date}
};


%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

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
barht=13;

if 0, % long comment
  posH=get(c.x.AuthorHonorific,'Position');
  posF=get(c.x.AuthorFirstName,'Position');
  posS=get(c.x.AuthorSurname,'Position');
  
  right=sum(posS([1 3]));
  posH(3)=min(50,posH(3));
  
  width=right-sum(posH([1 3]))-2;
  posF(1)=sum(posH([1 3]))+1;
  
  posF(3)=width/2;
  posS(1)=sum(posF([1 3]))+1;
  posS(3)=width/2;
  
  titlePos=get(c.x.AuthorHonorificTitle,'Position');
  
  set(c.x.AuthorHonorific,'Position',posH);
  set(c.x.AuthorFirstName,'Position',posF);
  set(c.x.AuthorSurname,'Position',posS);
  
  posH(2)=titlePos(2);
  posF(2)=titlePos(2);
  posS(2)=titlePos(2);
  set(c.x.AuthorHonorificTitle,'Position',posH);
  set(c.x.AuthorFirstNameTitle,'Position',posF);
  set(c.x.AuthorSurnameTitle,'Position',posS);
end % if 0

if c.x.lowLimit>c.x.yzero+3*c.x.pad+4*barht
   xStart=c.x.xzero+c.x.pad;
   xWid=c.x.xext-c.x.xzero-2*c.x.pad;
   
   editHeight=(c.x.lowLimit-c.x.yzero-2*barht-3*c.x.pad)/2;
   yTitle1=c.x.lowLimit-c.x.pad-barht;
   yEdit1=yTitle1-editHeight;
   yTitle2=yEdit1-c.x.pad-barht;
   yEdit2=yTitle2-editHeight;
   
   set(c.x.Abstract     ,'position',[xStart,yEdit1 ,xWid,editHeight]);
   set(c.x.AbstractTitle,'position',[xStart,yTitle1,xWid,barht]);
       
   set(c.x.Legal_Notice     ,'position',[xStart,yEdit2 ,xWid,editHeight]);
   set(c.x.Legal_NoticeTitle,'position',[xStart,yTitle2,xWid,barht]);   
   c.x.allInvisible=logical(0);
   
else,
   c.x.allInvisible=logical(1);
   
end

%c.x.lowLimit
% put in the 2 edit fields here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl,
  case 'Include_Copyright',
    set([c.x.Copyright_Date     ,c.x.Copyright_Holder, ...
          c.x.Copyright_DateTitle,c.x.Copyright_HolderTitle], ...
        'enable',onoff(c.att.Include_Copyright));
  case 'Include_Date',
    set(c.x.DateFormat,'enable',onoff(c.att.Include_Date));

  case 'DateFormat',
    %c.att.DateFormat
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=onoff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end

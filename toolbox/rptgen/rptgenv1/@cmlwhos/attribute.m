function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:42 $

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

dispFrame=controlsframe(c,'Display Options');

c=controlsmake(c);
set(c.x.SourceTitle,'HorizontalAlignment','left');

c.x.ColumnsTitle=uicontrol(c.x.all,...
   'Style','text',...
   'String','Columns in table ',...
   'HorizontalAlignment','left');

dispFrame.FrameContent={c.x.TitleTypeTitle c.x.TitleType(1)
   [5] {c.x.TitleType(2) c.x.TableTitle}
   [5] [5]
   c.x.ColumnsTitle {c.x.isSize
      c.x.isBytes
      c.x.isClass
      c.x.isValue}};

c.x.LayoutManager={
   c.x.SourceTitle
   {'indent' c.x.Source(1)
      [] {c.x.Source(2) num2cell(c.x.Filename)}}
   [10 10]
   dispFrame};

c=resize(c);
set(c.x.Filename,'enable',...
   onoff(strcmp(c.att.Source,'MATFILE')));   
set([c.x.TableTitle],'enable',...
   onoff(strcmp(c.att.TitleType,'manual')));   
LocAutoText(c);

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
case 'Source'
   set(c.x.Filename,'enable',...
      onoff(strcmp(c.att.Source,'MATFILE')));
   LocAutoText(c);
case 'Filename'
   LocAutoText(c);
case 'TitleType'
   set([c.x.TableTitle],'enable',...
      onoff(strcmp(c.att.TitleType,'manual')));   
end

      
%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocAutoText(c)

if strcmp(c.att.Source,'MATFILE')
   autoName=sprintf('File %s', parsevartext(c,c.att.Filename)); 
else
   autoName='MATLAB Workspace';
end

autoTitle=sprintf('Variables from %s', autoName);   

set(c.x.TitleType(1),...
	'String',sprintf('Automatic (%s)', autoTitle ));
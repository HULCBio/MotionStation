function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:46 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

titleFrame=controlsframe(c,'Section title ');
typeFrame=controlsframe(c,'Section type ');

%c.ref.allTypes={'Chapter' 'Chapter' 2.25
%   'Sect1' 'Section 1' 1.75
%   'Sect2' 'Section 2' 1.5
%   'Sect3' 'Section 3' 1.25
%   'Sect4' 'Section 4' 1
%   'Sect5' 'Section 5' 1
%   'SimpleSect' 'Simple Section' 1
%   'FormalPara' 'Titled Paragraph' 1
%   'Para' 'Untitled Paragraph' 1
%   '' 'No section' 1};

c=controlsmake(c);

%fontBase=get(0,'defaultuicontrolfontsize')

for i=length(c.ref.allTypes):-1:1
   c.x.TypeText(i)=uicontrol(c.x.all,...
      'style','text',... %'FontSize',fontBase*c.x.allTypes{i,3},...
      'horizontalalignment','left',...
      'String',[c.ref.allTypes{i,2} '        ']);   
   indentedLayout{i,1}={[10*(i-1) 1] c.x.TypeText(i)};
end

UpdateEnable(c);

typeFrame.FrameContent=indentedLayout;

titleFrame.FrameContent={
	c.x.isTitleFromSubComponent(1)
	{c.x.isTitleFromSubComponent(2) c.x.SectionTitle}
	[5]
	c.x.NumberMode(1)
	{c.x.NumberMode(2) c.x.Number}
	};

c.x.LayoutManager={titleFrame
   [5]
   typeFrame};

c=resize(c);

c.x.oldDepth=0;
UpdateSectionBold(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

UpdateSectionBold(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);


switch whichControl
case 'isTitleFromSubComponent'
   c=controlsupdate(c,whichControl,varargin{:});
   UpdateEnable(c);
case 'SectionTitle'
   oldTitle=c.att.SectionTitle;
   c=controlsupdate(c,whichControl,varargin{:});
   if isempty(c.att.SectionTitle)
      c.att.SectionTitle=oldTitle;
      set(c.x.SectionTitle,'String',oldTitle);
      errString='Section title must not be empty';
   else
      errString='';      
   end
   statbar(c,errString,~isempty(errString));
case 'NumberMode'
   c=controlsupdate(c,whichControl,varargin{:});
   UpdateEnable(c);
otherwise
   c=controlsupdate(c,whichControl,varargin{:});
end

UpdateSectionBold(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateEnable(c)

if c.att.isTitleFromSubComponent
   set(c.x.SectionTitle,'Enable','off');
else
   set(c.x.SectionTitle,'Enable','on');
end

if strcmp(c.att.NumberMode,'auto')
   set(c.x.Number,'Enable','off');
else
   set(c.x.Number,'Enable','on');
end
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateSectionBold(c)

d=getsectiondepth(c);
if d~=c.x.oldDepth
   c.x.oldDepth=d;
   set(c.x.TypeText,'FontWeight','normal');
   set(c.x.TypeText(d),'FontWeight','bold');
end

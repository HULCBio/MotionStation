function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:59 $

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

loopFrame=controlsframe(c,'Loop Type');
variFrame=controlsframe(c,'Workspace Variable');
prevFrame=controlsframe(c,'Preview');

c=controlsmake(c);

c.x.PreviewText=uicontrol(c.x.all,...
      'style','text',...
      'horizontalAlignment','left',...
      'String','',...
      'FontName',fixedwidthfont(c));


%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

loopFrame.FrameContent={
   c.x.LoopType(1)
   {'indent' c.x.StartNumberTitle c.x.StartNumber
      [1] c.x.IncrementNumberTitle c.x.IncrementNumber
      [1] c.x.EndNumberTitle c.x.EndNumber}
   c.x.LoopType(2)
   {'indent' c.x.LoopVectorTitle c.x.LoopVector}
};

variFrame.FrameContent={
   c.x.isUseVariable
   {'indent' c.x.VariableNameTitle c.x.VariableName}
   {'indent' c.x.isCleanup}
};

prevFrame.FrameContent={
   c.x.PreviewText
   [inf 1]
};

c.x.LayoutManager={
   loopFrame
   [3]
   variFrame
   [3]
   prevFrame
};

c=EnableControls(c);

%myText={'for '
%   '='
%   ':'
%   ':'
%   '    %run subcomponents'
%   'end'};

%for i=length(myText):-1:1
%   c.x.fillerText(i)=uicontrol(c.x.all,...
%      'style','text',...
%      'horizontalAlignment','center',...
%      'String',myText{i},...
%      'FontWeight','bold',...
%      'FontName',fixedwidthfont(c));
%end

%set(c.x.fillerText([1,5:6]),'HorizontalAlignment','left');

%c.x.LayoutManager={[5]
%   {c.x.fillerText(1) c.x.VariableName c.x.fillerText(2) ...
%         c.x.StartNumber c.x.fillerText(3) c.x.IncrementNumber ...
%         c.x.fillerText(4) c.x.EndNumber}
%   [5]
%   c.x.fillerText(5)
%   [5]
%   c.x.fillerText(6)
%   [5]
%   c.x.isUseVariable};

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);
%pad=10;
%barht=15;

%widthShare=[1.5 6 1 2 1 2 1 2];
%widthHandle=[c.x.fillerText(1) c.x.VariableName c.x.fillerText(2) ...
%      c.x.StartNumber c.x.fillerText(3) c.x.IncrementNumber ...
%      c.x.fillerText(4) c.x.EndNumber];

%allWidth=c.x.xext-c.x.xzero-2*pad;
%widthUnit=allWidth/sum(widthShare);

%pos=[c.x.xzero+pad c.x.ylim-2*pad 0 barht];
%for i=1:length(widthShare);
%   pos(3)=widthShare(i)*widthUnit;
%   set(widthHandle(i),'Position',pos);
%   pos(1)=pos(1)+pos(3);
%end

%pos=[c.x.xzero+pad pos(2)-barht-5 allWidth barht];
%set(c.x.fillerText(5),'position',pos);
%pos(2)=pos(2)-barht-5;
%set(c.x.fillerText(6),'position',pos);
%pos(2)=pos(2)-barht-10;
%set(c.x.isUseVariable,'position',pos);
%pos(2)=pos(2)-barht;
%indent=20;
%pos(1)=pos(1)+indent;
%pos(3)=pos(3)-indent;
%set(c.x.isCleanup,'position',pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

c=EnableControls(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=LocOnOff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EnableControls(c);

set([c.x.VariableName c.x.isCleanup],...
   'enable',LocOnOff(c.att.isUseVariable));

set([c.x.StartNumber c.x.IncrementNumber c.x.EndNumber],...
   'enable',LocOnOff(strcmp(c.att.LoopType,'$increment')));

set([c.x.LoopVector],...
   'enable',LocOnOff(strcmp(c.att.LoopType,'$vector')));

set(c.x.PreviewText,'String',...
   sprintf('%s\n     %%run child components\nend',outlinestring(c)));

function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:00 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

contextFrame=controlsframe(c,'Include Variables');
optFrame=controlsframe(c,'Table Columns');
renderFrame=controlsframe(c,'Table Display');

slCD=getslcdata(c);
c.x.LoopImage=uicontrol(c.x.all,...
   'style','togglebutton',...
   'Enable','inactive',...
   'Value',1,...
   'Cdata',slCD.ModelLarge);
c.x.LoopEcho=uicontrol(c.x.all,...
   'Style','text',...
   'String','Workspace variables from reported blocks in current model',...
   'HorizontalAlignment','left');

c=controlsmake(c);

contextFrame.FrameContent={c.x.LoopImage,[5],...
      {c.x.LoopEcho;c.x.isWorkspaceIO}};

checkPanel={
    c.x.isShowParentBlock
    c.x.isShowCallingString
    c.x.isShowVariableSize
    c.x.isShowVariableMemory
    c.x.isShowVariableClass
    c.x.isShowVariableValue
    c.x.isShowTunableProps
};
verNum=version;
if verNum(1)=='5'
    optFrame.FrameContent=checkPanel;
    %no data object parameters in R11
    set([c.x.ParameterPropsTitle;c.x.ParameterProps],'position',[-1000 -1000 5 5]);
else
    optFrame.FrameContent={checkPanel,...
            {c.x.ParameterPropsTitle;c.x.ParameterProps}
    };
end

set(c.x.ParameterPropsTitle,'HorizontalAlignment','left');

renderFrame.FrameContent={c.x.TableTitleTitle c.x.TableTitle
   [5] c.x.isBorder};

c.x.LayoutManager={contextFrame
   [5]
   optFrame
   [5]
   renderFrame};

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

c=controlsupdate(c,whichControl,varargin{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


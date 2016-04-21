function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:37 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)


c=controlsmake(c);


myText={'while ('
   ')'
   '    %run subcomponents'
   'end'};

for i=length(myText):-1:1
   c.x.fillerText(i)=uicontrol(c.x.all,...
      'style','text',...
      'horizontalAlignment','left',...
      'String',myText{i},...
      'FontWeight','bold',...
      'FontName',fixedwidthfont(c));
end

%set(c.x.fillerText([),'HorizontalAlignment','left');

c.x.LayoutManager={[10]
   {c.x.fillerText(1) c.x.ConditionalString c.x.fillerText(2)}
   c.x.fillerText(3)
   c.x.fillerText(4)
   [10]
   {c.x.isMaxIterations c.x.MaxIterations}};

c=LocReviseNumLoops(c);


c=resize(c);

set([c.x.MaxIterations],...
   'enable',LocOnOff(c.att.isMaxIterations));

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
case 'MaxIterations'
   c=LocReviseNumLoops(c);
case 'isMaxIterations'
   set([c.x.MaxIterations],...
      'enable',LocOnOff(c.att.isMaxIterations));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocReviseNumLoops(c)

newNL=floor(c.att.MaxIterations);
c.att.MaxIterations=newNL;
set(c.x.MaxIterations,'Value',newNL);
set(c.x.isMaxIterations,'String',...
   sprintf('Limit number of loops to:  %d ', newNL ));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=LocOnOff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end

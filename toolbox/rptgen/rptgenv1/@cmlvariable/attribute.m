function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:35 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

sourceControls=controlsframe(c,'Variable to Include ');
renderControls=controlsframe(c,'Render Options');

c=controlsmake(c);

sourceControls.FrameContent=   {c.x.sourceTitle c.x.source(1)
      [2] {c.x.source(2) num2cell(c.x.filename)}
      [2] c.x.source(3)
      [3] [inf 3]
      c.x.variableTitle c.x.variable};

renderControls.FrameContent={{c.x.renderAsTitle num2cell(c.x.renderAs')
      [5] [inf 5]}
   c.x.forceinline
   [3]
   c.x.sizeLimit};

c.x.LayoutManager={sourceControls
   [5]
   renderControls};

set(c.x.filename,'enable',...
   LocOnOff(strcmp('M',c.att.source)));


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

switch whichControl
case 'variable'
   vString=get(c.x.variable,'string');
   if isempty(findstr(vString,'%<'))
      [c.att.variable,errMsg]=rptgenutil(...
         'VariableNameCheck',c.x.variable,...
         c.att.variable,logical(1));
      statbar(c,errMsg,~isempty(errMsg));
   else
      c.att.variable=vString;
   end
case 'source'
   c=controlsupdate(c,whichControl,varargin{:});
   set(c.x.filename,'enable',...
      LocOnOff(strcmp('M',c.att.source)));
otherwise
   c=controlsupdate(c,whichControl,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

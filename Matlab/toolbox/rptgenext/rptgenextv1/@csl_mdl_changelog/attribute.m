function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:55 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

colFrame=controlsframe(c,'Table Columns');
tableFrame=controlsframe(c,'Table Display');
c=controlsmake(c);


colFrame.FrameContent={
   c.x.isAuthor
   c.x.isVersion
   c.x.isDate %{c.x.isDate c.x.DateFormat}
   c.x.isComment
};

tableFrame.FrameContent={
   c.x.TableTitleTitle c.x.TableTitle
   [5] c.x.isBorder
};

c.x.LayoutManager={
   [5]
   {c.x.isLimitRevisions,c.x.numRevisions}
   [5]
   colFrame
   [5]
   tableFrame
};



c=resize(c);

set(c.x.numRevisions,'Enable',LocOnOff(c.att.isLimitRevisions));
%set(c.x.DateFormat,'enable',LocOnOff(c.att.isDate));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

statMsg='';
statErr=logical(0);

c=controlsupdate(c,whichControl,varargin{:});   
switch whichControl
case 'isLimitRevisions'
   set(c.x.numRevisions,'Enable',LocOnOff(c.att.isLimitRevisions));
case {'isAuthor' 'isDate' 'isComment' 'isVersion'}
   if ~any([c.att.isAuthor c.att.isDate c.att.isComment c.att.isVersion])
      c.att=setfield(c.att,whichControl,logical(1));
      set(getfield(c.x,whichControl),'Value',logical(1));
      statMsg='At least one column must be selected';
      statErr=logical(1);
   end
   %set(c.x.DateFormat,'enable',LocOnOff(c.att.isDate));
end

statbar(c,statMsg,statErr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


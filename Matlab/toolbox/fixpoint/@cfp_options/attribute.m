function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:36 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

prefFrame=controlsframe(c,'Log Min & Max');
mergeFrame=controlsframe(c,'Log Mode');
dblFrame=controlsframe(c,'Doubles Override');

c=controlsmake(c);

%vvvvvvvvvvvvvvvvvvvvvvvvvvvvv
%These lines temporarily added to resolve
%a corruption in Perfect
c.x.FixLogPrefTitle = [];
c.x.FixLogMergeTitle = [];
c.x.FixUseDblTitle =[];
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set([c.x.FixLogPrefTitle,c.x.FixLogMergeTitle,c.x.FixUseDblTitle],...
   'HorizontalAlignment','left');

prefFrame.FrameContent={
   c.x.FixLogPrefTitle
   num2cell(c.x.FixLogPref')
};

mergeFrame.FrameContent={
   c.x.FixLogMergeTitle
   num2cell(c.x.FixLogMerge')
};

dblFrame.FrameContent={
   c.x.FixUseDblTitle
   num2cell(c.x.FixUseDbl')
};

c.x.LayoutManager={
   prefFrame
   [5]
   dblFrame
   [5]
   mergeFrame
};

c=resize(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin)

c=controlsupdate(c,whichControl,varargin{:});   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


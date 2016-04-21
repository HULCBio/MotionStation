function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:54 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

if ischar(c.att.Content)
   c.att.Content = cellstr(c.att.Content);
end

c=controlsmake(c,{'Content','isEmphasis','isLiteral'});

set(c.x.ContentTitle,...
   'HorizontalAlignment','left');

c=resize(c);

LocChangeText(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

resizeHandles=[c.x.ContentTitle c.x.Content c.x.isEmphasis c.x.isLiteral];

barHt=15;
pad=5;

xStart=c.x.xzero+pad;
yStart=c.x.yzero+pad;

pageWid=c.x.xlim-c.x.xzero-2*pad;
pageHt=c.x.ylim-c.x.yzero-2*pad;

editHt=pageHt-3*barHt;

resizePositions={[xStart yStart+2*barHt+editHt pageWid barHt]
   [xStart yStart+2*barHt pageWid editHt]
   [xStart yStart+1*barHt pageWid barHt]
   [xStart yStart pageWid barHt]};

set(resizeHandles,{'Position'},resizePositions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);


c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'isEmphasis'
   LocChangeText(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocChangeText(c)

if c.att.isEmphasis
   set(c.x.Content,'FontAngle','italic');
else
   set(c.x.Content,'FontAngle','normal');
end   
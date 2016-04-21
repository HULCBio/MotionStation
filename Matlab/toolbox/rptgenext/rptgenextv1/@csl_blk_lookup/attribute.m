function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:25 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

frameMain=controlsframe(c,'Display Options');
frameTitle=controlsframe(c,'Figure/Table Title');
frameImage=controlsframe(c,'Image');

c=controlsmake(c);

frameMain.FrameContent={
   {c.x.isSinglePlot c.x.SinglePlotType}
   c.x.isSingleTable
   [3]
   {c.x.isDoublePlot c.x.DoublePlotType}
   c.x.isDoubleTable
   [3]
   c.x.isMultiTable
};

frameTitle.FrameContent={
   c.x.TitleType(1)
   c.x.TitleType(2)
   {c.x.TitleType(3) c.x.TitleString}
};

frameImage.FrameContent={
   c.x.ImageFormatTitle c.x.ImageFormat
   c.x.PaperOrientationTitle c.x.PaperOrientation
   c.x.PrintSizeTitle {c.x.PrintSize c.x.PrintUnits}
   };

c.x.LayoutManager={
   frameMain
   [3]
   frameTitle
   [3]
   frameImage
};

enableControls(c);
cString=[num2str(c.att.PrintSize(1)) 'x' ...
      num2str(c.att.PrintSize(2))];
set(c.x.PrintSize,'String',cString);

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

if strcmp(whichControl,'PrintSize')
   [c.att.PrintSize,errMsg]=rptgenutil('str2numNxN',...
      c.x.PrintSize,c.att.PrintSize);   
   statbar(c,errMsg,~isempty(errMsg));
elseif strcmp(whichControl,'PrintUnits')
   oldUnits=c.att.PrintUnits;
   c=controlsupdate(c,whichControl,varargin{:});
   newUnits=c.att.PrintUnits;
   c.att.PrintSize=rptgenutil('SizeUnitTransform',...
      c.att.PrintSize,...
      oldUnits,...
      newUnits,...
      c.x.PrintSize);
else
   c=controlsupdate(c,whichControl,varargin{:});
	enableControls(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableControls(c)

set(c.x.SinglePlotType,'Enable',onoff(c.att.isSinglePlot));
set(c.x.DoublePlotType,'Enable',onoff(c.att.isDoublePlot));
set(c.x.TitleString,'Enable',onoff(strcmp(c.att.TitleType,'manual')));
function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
%   C=ATTRIBUTE(C,'Action',argin1,argin2,....)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:17 $

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

printOptFrame=controlsframe(c,'Print Options');

c=controlsmake(c,{'isCapture',...
      'PaperOrientation',...
      'isResizeFigure',...
      'PrintSize',...
      'PrintUnits',...
      'InvertHardcopy',...
      'ImageFormat'});

iString=get(c.x.ImageFormat,'String');
iUserData=get(c.x.ImageFormat,'UserData');
imgInfo=getimgformat(c,'AUTOHG');
autoIndex=find(strcmp(iUserData,'AUTOHG'));
iString{autoIndex}=sprintf('Automatic (%s)', imgInfo.name );
set(c.x.ImageFormat,'String',iString);

cString=[num2str(c.att.PrintSize(1)) 'x' ...
      num2str(c.att.PrintSize(2))];
set(c.x.PrintSize,'String',cString);

printOptFrame.FrameContent={c.x.isCapture
   {c.x.PaperOrientationTitle num2cell(c.x.PaperOrientation')
      [5] [5]
      c.x.isResizeFigureTitle c.x.isResizeFigure(1)
      'indent' c.x.isResizeFigure(2)
      'indent' {c.x.isResizeFigure(3),...
            c.x.PrintSize c.x.PrintUnits}
      [5] [5]
      c.x.InvertHardcopyTitle num2cell(c.x.InvertHardcopy')}};

c.x.LayoutManager={[4 4]
   {c.x.ImageFormatTitle c.x.ImageFormat}
   [10 10]
   printOptFrame};

LocEnable(c,'isCapture');

CaptureWarn(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

CaptureWarn(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

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
   LocEnable(c,whichControl);
   CaptureWarn(c);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocEnable(c,action);

switch action
case 'isCapture'
   set([c.x.PaperOrientation c.x.isResizeFigure c.x.PrintSize ...
         c.x.PrintUnits c.x.InvertHardcopy],'Enable',...
      LocOnOff(~c.att.isCapture));
   if ~c.att.isCapture
      LocEnable(c,'isResizeFigure')
   end   
case 'isResizeFigure'
   set([c.x.PrintSize c.x.PrintUnits],'Enable',...
      LocOnOff(strcmp(c.att.isResizeFigure,'manual')));   
end

   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CaptureWarn(c)

imgInfo=getimgformat(c,c.att.ImageFormat);

captureImageExt={'tif'
   'tiff'
   'jpg'
   'jpeg'
   'bmp'
   'png'
   'hdf'
   'pcx'
   'xwd'};

if ~any(strcmpi(captureImageExt,imgInfo.ext)) & ...
      c.att.isCapture
   warnStr=sprintf('Warning - image format type "%s" can not be used with "capture".',...
      imgInfo.ext);
else
   warnStr='';
end

statbar(c,warnStr,~isempty(warnStr));   

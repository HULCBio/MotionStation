function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:50 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

paperFrame=controlsframe(c,'Snapshot Options');

c=controlsmake(c);
% ,{'format',...
%       'TitleType',...
%       'TitleString',...
%       'PaperOrientation',...
%       'isPrintFrame',...
%       'PrintFrameName',...
%       'CaptionType',...
%       'CaptionString'});

iString=get(c.x.format,'String');
iUserData=get(c.x.format,'UserData');
imgInfo=getimgformat(c,'AUTOSL');
autoIndex=find(strcmp(iUserData,'AUTOSL'));
iString{autoIndex}=sprintf('Automatic (%s)', imgInfo.name );
set(c.x.format,'String',iString);


cString=[num2str(c.att.PaperExtent(1)) 'x' ...
      num2str(c.att.PaperExtent(2))];
set(c.x.PaperExtent,'String',cString);

enableControls(c);

paperFrame.FrameContent={
   c.x.formatTitle c.x.format
   [5] [5]
   c.x.PaperOrientationTitle num2cell(c.x.PaperOrientation')
   c.x.PaperExtentModeTitle {c.x.PaperExtentMode,c.x.PaperExtent,c.x.PaperUnits}
   [5] [5]
   c.x.TitleTypeTitle {
       c.x.TitleType(1)
       c.x.TitleType(2)
       c.x.TitleType(3)
       {c.x.TitleType(4) c.x.TitleString}
   }
   [2] [2]
   c.x.CaptionTypeTitle {
      c.x.CaptionType(1)
      c.x.CaptionType(2)
      {c.x.CaptionType(3) c.x.CaptionString}
   }
};

c.x.LayoutManager={[5]
   {c.x.isPrintFrame num2cell(c.x.PrintFrameName)}
   [10]
   paperFrame};

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

switch whichControl
case 'PaperUnits'
   oldUnits=c.att.PaperUnits;
   c=controlsupdate(c,whichControl,varargin{:});
   newUnits=c.att.PaperUnits;
   c.att.PaperExtent=rptgenutil('SizeUnitTransform',...
      c.att.PaperExtent,...
      oldUnits,...
      newUnits,...
      c.x.PaperExtent);
case 'PaperExtent'
       [c.att.PaperExtent,errMsg]=rptgenutil('str2numNxN',...
      c.x.PaperExtent,c.att.PaperExtent);   
case {'format','PaperExtentMode','CaptionType','TitleType','isPrintFrame'}
   c=controlsupdate(c,whichControl,varargin{:});  
   enableControls(c);
otherwise
   c=controlsupdate(c,whichControl,varargin{:});   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableControls(c)

set(c.x.PaperOrientation,'Enable',...
    onoff(~strcmp(c.att.format,'png-capture')));

set(c.x.PrintFrameName,'Enable',...
    onoff(c.att.isPrintFrame));
set(c.x.PaperExtentMode,'Enable',...
    onoff(~c.att.isPrintFrame));

set(c.x.CaptionString,'Enable',...
   onoff(strcmp(c.att.CaptionType,'$manual')));

set(c.x.TitleString,'Enable',...
   onoff(strcmp(c.att.TitleType,'manual')));

set([c.x.PaperExtent c.x.PaperUnits],...
      'enable',onoff(strcmp(c.att.PaperExtentMode,'manual')));

  
  
warnStr=checkframeformat(c);
statbar(c,warnStr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


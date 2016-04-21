function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:23 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

nameFrame=controlsframe(c,'Show Name of Current: ');
renderFrame=controlsframe(c,'Render Name As: ');

c=controlsmake(c);

cdata=gethgcdata(c);

set(c.x.ObjType,'String','',...
   {'cdata'},{cdata.FigureLarge;...
            cdata.AxesLarge;...
            cdata.ObjectLarge});
      
c.x.ExampleStringTitle=uicontrol(c.x.all,...
   'Style','text',...
   'FontAngle','italic',...
   'String','(Sample) ',...
   'HorizontalAlignment','left');

c.x.ExampleString=uicontrol(c.x.all,...
   'Style','text',...
   'FontWeight','bold',...
   'HorizontalAlignment','left');

spacer=[-inf 5];
nameFrame.FrameContent={[3];...
      {c.x.ObjType(1) spacer c.x.ObjType(2) spacer ...
         c.x.ObjType(3)}};

renderFrame.FrameContent={{c.x.ExampleStringTitle c.x.ExampleString
      [3] [inf 3]}
   {num2cell(c.x.renderAs')}};

c.x.LayoutManager={nameFrame
   [5]
   renderFrame};

LocExampleString(c);

c=resize(c);

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

LocExampleString(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eString=LocExampleString(c)

oType=c.att.ObjType;

switch oType
case 'Figure'
   oName='FigName';
case 'Axes'
   oName='AxName';
case 'Object'
   oName='ObjName';
otherwise
   oName='Name';
   oType='Type';
end

switch c.att.renderAs
case 't n'
   eString=[oType ' ' oName];
case 't-n'
   eString=[oType ' - ' oName];
case 't:n'
   eString=[oType ': ' oName];
otherwise %case 'n'
   eString=oName;   
end

set(c.x.ExampleString,'String',eString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

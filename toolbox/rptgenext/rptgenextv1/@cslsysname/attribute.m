function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:10 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

nameFrame=controlsframe(c,'Show name of current: ');
renderFrame=controlsframe(c,'Render name as: ');

c=controlsmake(c);

c.x.ExampleStringTitle=uicontrol(c.x.all,...
   'Style','text',...
   'FontAngle','italic',...
   'String','(Sample) ',...
   'HorizontalAlignment','left');

c.x.ExampleString=uicontrol(c.x.all,...
   'Style','text',...
   'FontWeight','bold',...
   'HorizontalAlignment','left');

%c.x.HelpText=uicontrol(c.x.all,...
%   'style','text',...
%   'string',help('cslsysname'),...
%   'HorizontalAlignment','left');

cdata=getslcdata(c.zslmethods);

set(c.x.ObjectType(2:5),{'cdata'},{cdata.ModelLarge;...
      cdata.SystemLarge;...
      cdata.BlockLarge;...
      cdata.SignalLarge},'String','');

spacer=[-inf 5];
nameFrame.FrameContent={[3]
      c.x.ObjectType(1)
   {c.x.ObjectType(2) spacer c.x.ObjectType(3) spacer ...
         c.x.ObjectType(4) spacer c.x.ObjectType(5)}};

renderFrame.FrameContent={{c.x.ExampleStringTitle c.x.ExampleString;[3] [inf 3]}
   num2cell(c.x.renderAs')
   [5]
   c.x.isfullname};

c.x.LayoutManager={nameFrame
   [5]
   renderFrame};

UpdateAutoText(c);

set(c.x.isfullname,'Enable',...
   onoff(~any(strcmp({'Model' 'Signal'},c.att.ObjectType))));

LocExampleString(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

UpdateAutoText(c);
LocExampleString(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%if c.x.lowLimit>c.x.yzero+2*c.x.pad+40
%   pos=[c.x.xzero+c.x.pad...
%         c.x.yzero+c.x.pad...
%         c.x.xext-c.x.xzero-2*c.x.pad,...
%         c.x.lowLimit-c.x.yzero-2*c.x.pad];
%   set(c.x.HelpText,'position',pos);
%else
%   c.x.allInvisible=logical(1);
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

switch whichControl
case 'ObjectType'
   set(c.x.isfullname,'Enable',...
      onoff(~any(strcmp({'Model' 'Signal'},c.att.ObjectType))));
end

LocExampleString(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eString=LocExampleString(c)

if strcmp(c.att.ObjectType,'Automatic')
   oType=getparentloop(c);
   if isempty(oType)
      oType='Model';
   end
else
   oType=c.att.ObjectType;
end

switch oType
case 'Model'
   oName='f14';
   pName='';   
case 'System'
   oName='Aircraft Dynamics Model';
   pName='f14/';   
case 'Signal'
   oName='w';
   pName='';   
case 'Block'
   oName='Gain4';
   pName='f14/Aircraft Dynamics Model/';
otherwise
   oName='Name';
   pName='Parent/';
   oType='Type';
end


if c.att.isfullname
   oName=[pName oName];
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
function UpdateAutoText(c)

oType=getparentloop(c);
if isempty(oType)
   oType='Model';
end

set(c.x.ObjectType(1),'String',sprintf('Automatic (%s)', oType ));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:57 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)


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



renderFrame.FrameContent={{c.x.ExampleStringTitle c.x.ExampleString;[3] [inf 3]}
   num2cell(c.x.renderAs')
   [5]
   c.x.isfullname; 
	{'indent' c.x.issimulinkname}
   };

c.x.LayoutManager={renderFrame};



set(c.x.isfullname,'Enable','on' );
set(c.x.issimulinkname,'Enable',onoff(c.att.isfullname) );

LocExampleString(c);
UpdateTitle(c);
c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


LocExampleString(c);
UpdateTitle(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});


set(c.x.isfullname,'Enable','on' );
set(c.x.issimulinkname,'Enable',onoff(c.att.isfullname) );

LocExampleString(c);
UpdateTitle(c);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eString=LocExampleString(c)

% determine object type here:
parent = rgsf( 'get_sf_parent', c );
if ~rgsf( 'is_parent_valid', c )
   oName = 'myObject';
   pName = 'sfPath/';
   oType = 'Object';
else  % parent is valid and everything is OK
   oType = rgsf( 'get_parent_type', c );
   oName = ['my',oType,'Name'];
   pName = ['sf',oType,'Path/'];  
end   
if c.att.isfullname
   oName=[pName oName];
   if c.att.issimulinkname
   	oName = [ 'mySLPath/' oName ];
	end   
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
function UpdateTitle(c)
 
if ~rgsf('is_parent_valid', c )
	set( c.x.title, 'String', 'Stateflow Object Name (invalid parent)' );
   [validity, errMsg] = rgsf( 'is_parent_valid', c );
   statbar(c, sprintf('Error: this component %s', xlate(errMsg)) ,1);
else
	parent = rgsf( 'get_sf_parent', c ); %if we got here, parent may not be empty
	set( c.x.title, 'String', outlinestring(c) );
   statbar(c, '', 0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=onoff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end


function str = capitalize1( str )
if ~isempty(str)
   str(1) = upper( str(1) );
end

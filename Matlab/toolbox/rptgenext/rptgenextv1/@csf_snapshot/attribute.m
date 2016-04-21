function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:29 $

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

printOptFrame=controlsframe(c,'Image Size');

c=controlsmake(c,{'imageSizing','PrintSize','PrintUnits',...
		'ImageFormat', 'picMinChildren','isCallouts','TitleType','TitleString'});

%c.x.minChildrenSuffix=uicontrol(c.x.all,...
%	'Style','text',...
%	'horizontalAlignment','left',...
%   'String','children');

% The spaces in the following string are not ASCII 32, but ASCII 255,
% to prevent wrapping of strings. (HG peculiarity)
%c.x.minChildrenSuffix2=uicontrol(c.x.all,...
%	'Style','text',...
%	'horizontalAlignment','left',...
%   'String','for picture');

iString=get(c.x.ImageFormat,'String');
iUserData=get(c.x.ImageFormat,'UserData');
imgInfo=getimgformat(c,'AUTOSF');
autoIndex=find(strcmp(iUserData,'AUTOSF'));
iString{autoIndex}=sprintf('Automatic (%s)', imgInfo.name );
set(c.x.ImageFormat,'String',iString);
set(c.x.picMinChildrenTitle,'HorizontalAlignment','left');

cString=[num2str(c.att.PrintSize(1)) 'x' ...
        num2str(c.att.PrintSize(2))];
set(c.x.PrintSize,'String',cString);

printOptFrame.FrameContent={
    {  num2cell(c.x.imageSizing') }
    [5]
    {  c.x.PrintSizeTitle c.x.PrintSize c.x.PrintUnits }
};

c.x.LayoutManager={
    {c.x.ImageFormatTitle c.x.ImageFormat}
    [5]
    c.x.picMinChildrenTitle
    c.x.picMinChildren
    [5]
    c.x.isCallouts
    [5]
    {c.x.TitleTypeTitle {
            c.x.TitleType(1)
            c.x.TitleType(2)
            c.x.TitleType(3)
            c.x.TitleType(4)
            {c.x.TitleType(5) c.x.TitleString}}}
    [5]
    printOptFrame};

c=resize(c);
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c)
   
if ~rgsf('is_parent_valid', c )
	set( c.x.title, 'String', 'Stateflow Snapshot (invalid parent)' );
   [validity, errMsg] = rgsf( 'is_parent_valid', c );
   statbar(c, sprintf('Error: this component %s', xlate(errMsg)) ,1);
else
	parent = rgsf( 'get_sf_parent', c ); %if we got here, parent may not be empty
	set( c.x.title, 'String', sprintf('Stateflow Snapshot (%s)', parent.att.typeString ) );
   statbar(c, '', 0);
end
%LocHandleValidity(c);



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
switch whichControl
case 'PrintSize',
   oldValue=c.att.PrintSize;
   cString=get(c.x.PrintSize,'String');
   notNumeric=find(abs(cString)<abs('0') | abs(cString)>abs('9'));
   [cString(notNumeric)]=deal(' ');
   nums=[];
   while ~all(isspace(cString))
      [numStr,cString]=strtok(cString);
      nums=[nums str2double(numStr)];
   end
   if length(nums)<1
      nums=oldValue;
      sString='Please enter size values as NxN';
   elseif length(nums)==1
      nums=[nums nums];
      sString='Please enter size values as NxN';
   elseif length(nums)>2
      nums=nums(1:2);
      sString='Please enter size values as NxN';
   else
      sString='';
   end
   set(c.x.statusbar,'String',sString);
   c.att.PrintSize=nums;
	if nargin < 3 | ~strcmp( varargin{1}, 'callFromPrintUnits' )
		Update( c,'PrintUnits', 'callFromPrintSize'); %update size in points
	end
   cString=[num2str(nums(1)) 'x' num2str(nums(2))];
   set(c.x.PrintSize,'String',cString);
case 'PrintUnits',
	% convert the size into new units
	oldVal = c.att.PrintUnits;
	newVal = get( c.x.PrintUnits, 'Value' );
	strTable = {'inches','centimeters','points'};
	switch oldVal
	case 'inches'
		oldVal = 1;
	case 'centimeters'
		oldVal = 2;
	case 'points'
		oldVal = 3;
	end
	table = [ 1 2.54 72 ];
	scale = table( newVal ) / table( oldVal );
	c.att.PrintSize = c.att.PrintSize * scale;
	if nargin < 3 | ~strcmp( varargin{1}, 'callFromPrintSize' )
		myStr = [num2str(c.att.PrintSize(1)) 'x' num2str(c.att.PrintSize(2))];
		set( c.x.PrintSize, 'String', myStr ); 
		%Update( c, 'PrintSize', 'callFromPrintUnits' ); %update the size field
	end
	%now set the size in the points
	ptScale = table (3) / table( newVal );
	c.att.PrintSizePoints = c.att.PrintSize * ptScale;
	c.att.PrintUnits = strTable{newVal};
otherwise
   c=controlsupdate(c,whichControl,varargin{:});
   LocEnable(c,whichControl);
end
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocEnable(c,action);

switch action
case 'disableAll'
	   set(c.x.UIcontrolList ,'Enable','off');  	  
case 'isResizeFigure'
   set([c.x.PrintSize c.x.PrintUnits],'Enable',...
      LocOnOff(strcmp(c.att.isResizeFigure,'manual')));   
case 'TitleType'
    set(c.x.TitleString,'Enable',...
        LocOnOff(strcmp(c.att.TitleType,'manual')));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function LocHandleValidity(c)
%
%childrenSelObjs = [c.x.picMinChildrenTitle, c.x.picMinChildren, ...
%						 ... c.x.minChildrenSuffix, c.x.minChildrenSuffix2
%						 ];
%parent = rgsf( 'get_sf_parent', c );
%canHaveChildren = 1;
%if ~isempty( parent ) & isa(parent,'csf_obj_report')
%	canHaveChildren = rgsf('can_have_children',parent.att.typeString);
%end
%
%set(childrenSelObjs,...
%	'Enable',LocOnOff(canHaveChildren));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

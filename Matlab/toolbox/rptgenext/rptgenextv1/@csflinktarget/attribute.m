function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:50 $

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

c=controlsmake(c);


spacer=[-inf 5];
c.x.LayoutManager={   
   [10]
   {c.x.LinkTextTitle c.x.LinkText}};

c.x.HelpText=uicontrol(c.x.all,...
   'style','text',...
   'string',help('csflinktarget'),...
   'HorizontalAlignment','left');


%the attribute page is by default rendered in a
%two-column layout.  To change the layout of the
%uicontrols, change c.x.LayoutManager.

UpdateTitle(c);


c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

UpdateTitle(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);
if c.x.lowLimit>c.x.yzero+2*c.x.pad+40
   pos=[c.x.xzero+c.x.pad...
         c.x.yzero+c.x.pad...
         c.x.xext-c.x.xzero-2*c.x.pad,...
         c.x.lowLimit-c.x.yzero-2*c.x.pad];
   set(c.x.HelpText,'position',pos);
else
   c.x.allInvisible=logical(1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

c=controlsupdate(c,whichControl,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateTitle(c)
 
if ~rgsf('is_parent_valid', c )
	set( c.x.title, 'String', 'Stateflow Linking Anchor (invalid parent)' );
   [validity, errMsg] = rgsf( 'is_parent_valid', c );
   statbar(c, sprintf('Error: this component %s', xlate(errMsg)) ,1);
else
	parent = rgsf( 'get_sf_parent', c ); %if we got here, parent may not be empty
	set( c.x.title, 'String', outlinestring(c) );
   statbar(c, '', 0);
end


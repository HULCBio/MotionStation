function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:25 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c=controlsmake(c);

myChildren=children(c);
if length(myChildren)>0
   set(c.x.LinkText,...
      'String','Link text taken from subcomponents',...
      'Enable','off');
   set(c.x.isEmphasizeText,'Enable','off')
end


set([c.x.LinkTypeTitle c.x.LinkTextTitle c.x.LinkIDTitle],...
   'HorizontalAlignment','left');

linkLayout={{c.x.LinkTypeTitle num2cell(c.x.LinkType')}
   [3]
   c.x.LinkIDTitle
   {'indent' c.x.LinkID}};

textLayout={c.x.LinkTextTitle
   {'indent' c.x.LinkText
   'indent' c.x.isEmphasizeText}};

c.x.LayoutManager={linkLayout
   [10]
   textLayout};

ChangeLinkIdentifierTitle(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


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
switch whichControl
case 'LinkType'
   ChangeLinkIdentifierTitle(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeLinkIdentifierTitle(c);

switch lower(c.att.LinkType);
case 'link'
   idStr='Anchor ID to reference';
   %ltSuffix=xlate('(required for link type "Link")');
case 'ulink'
   idStr='Web URL (http://) to link';
   %ltSuffix=xlate('(required for link type "URL link")');
case 'anchor'
   idStr='Anchor ID to create';
   %ltSuffix=xlate('(optional for link type "Anchor")');
case 'xref'
   idStr='Text ID to insert';
   %ltSuffix=xlate('(optional for link type "Xref")');
otherwise
   idStr='Link ID';
   %ltSuffix='';
end
ltSuffix=xlate('(optional)');

set(c.x.LinkIDTitle,'String',idStr);
set(c.x.LinkTextTitle,'String',sprintf('Link text %s', ltSuffix)); 

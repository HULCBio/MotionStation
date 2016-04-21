function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:14 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%since we are using this component from the GUI,
%assume we're taking the cell table from the workspace
%c.att.isArrayFromWorkspace=logical(1);


c=controlsmake(c);

c.x.LayoutManager={
    [10]
	{c.x.typeStringTitle c.x.typeString}
	[10]
	{c.x.repMinChildrenTitle ''}
   c.x.repMinChildren
   [10]
   c.x.addAnchor
	};

LocHandleValidity(c);

c=resize(c);
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

c=controlsupdate(c,whichControl,varargin{:});

LocHandleValidity(c);

rptcp(c);

% ask to update my csf_snapshot and SF name children outlinestrings
myHandle=c.ref.ID;
if isa(myHandle,'rptcp')
   objList=findall(myHandle.h,...
      'type','uimenu',...
      'tag','csf_snapshot');
   
   if ~isempty(objList)
      outlinestring(rptcp(objList),2);
   end
   
   objList=findall(myHandle.h,...
      'type','uimenu',...
      'tag','csfobjname');
   
   if ~isempty(objList)
      outlinestring(rptcp(objList),2);
   end
end
refresh(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocHandleValidity(c)

childrenSelObjs = [c.x.repMinChildrenTitle, c.x.repMinChildren ];
set(childrenSelObjs,...
	'Enable',LocOnOff(rgsf('can_have_children',c.att.typeString)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c)

typeStr = c.att.typeString;
typeStr(1) = upper( typeStr(1) );
titleString=[typeStr char(32) 'Report'];

[validity, errMsg] = rgsf( 'is_parent_valid', c );
if ~validity
   titleString=sprintf('%s (invalid parent)',xlate(titleString));
   errString=sprintf('Error: this component %s', xlate(errMsg));
   errType=1;
else
   errString='';
   errType=0;
end

statbar(c,errString,errType);
set(c.x.title,'String',titleString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

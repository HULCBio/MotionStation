function out=tableref(p,z,refObj,action,varargin)
%TABLEREF proptable reference functions
%CheckContinue
%    Run at the beginning of execution.  If returns empty,
%    will create the proptable.  If returns a string, will
%    halt execution and display the string as an error
%    message.
%GetPropList(filter) - called whenever the filter changes. 
%    Gives a list of properties for the filter.
%GetFilterList - called on startup.  Gets a list of all 
%    valid filters
%GetPropCell(property) - called during execution.  Gives
%    the unparsed cell structure as well as the parsed property
%    name.
%GetPresetList-get a list of all preset tables for the "apply
%    preset table" popup menu.
%GetPresetTable(tablename) - returns a new attributes array
%    for the table.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:10 $


out=feval(action,z,refObj,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg=CheckContinue(z,objType);

if length(subsref(z,substruct('.',objType)))>0
   errorMsg='';
else
   errorMsg=sprintf('Warning - could not find %s for property table',objType);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  propList=GetPropList(z,objType,filter)

propList=feval(['prop' lower(objType)],...
   z,...
   'GetPropList',...
   filter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  filterList=GetFilterList(z,objType)

filterList.index=1;
filterList.list=feval(['prop' lower(objType)],...
   z,...
   'GetFilterList');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellContent=GetPropCell(z,objType,propname)

loopObj=subsref(z,substruct('.',objType));
if ~isnumeric(loopObj)
   loopObj={loopObj};
end

propValue=feval(['prop' lower(objType)],...
   z,...
   'GetPropValue',...
   loopObj,...
   propname);

if length(propValue)>0
   propValue=propValue{1};
else
   propValue='';
end

cellContent.name=propname;
cellContent.value=propValue;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList(z,objType);

list={'Blank 3x3'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

switch tablename
otherwise %blank 4x4
   title='Title';
   singleVal=logical(0);
   colWid=[1 1 1 1];
   [pnames{1:3,1:3}]=deal('');
end

if singleVal
   defaultAlign='c';
   defaultRender='P v';
else
   defaultAlign='l';
   defaultRender='P v';
end

content=struct('align',defaultAlign,...
   'text',pnames,...
   'border',3,...
   'render',defaultRender);

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content,...
   'TitleRender','v');


function out=tableref(c,action,varargin)
%TABLEREF interface for generic property table
%   OUT=TABLEREF(CSL_BLK_PROPTABLE,'ACTION')
%   Valid 'ACTION' strings:
%   GetPropList(filter) - called whenever the filter changes. 
%      Gives a list of properties for the filter.
%   GetFilterList - called on startup.  Gets a list of all 
%      valid filters
%   GetFormatList - called on startup.  Gets a list of valid
%      rendering options for the "display property as" popup
%   GetPropCell(cell,property) - called during execution.  Gives
%      the unparsed cell structure as well as the parsed property
%      name.
%   GetPresetList-get a list of all preset tables for the "apply
%      preset table" popup menu.
%   GetPresetTable(tablename) - returns a new attributes array
%      for the table.

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 16:55:18 $

switch action
case {'GetPropCell' 'CheckContinue'}
   out=feval(action,c.rptfpmethods,zslmethods,varargin{:});
case {'GetPresetList' 'GetPresetTable'}
   out=feval(action,varargin{:});
otherwise
   out=feval(action,c.rptfpmethods,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorMsg=CheckContinue(zF,zS)

blkID=zS.Block;
if ~isempty(blkID)
   errorMsg=['Warning - Fixed-Point property table only reports on Fixed-Point blocks'];
   try
      maskType=get_param(blkID,'MaskType');
      if strncmp('Fixed-Point ',maskType,length('Fixed-Point '))
         errorMsg='';
      end
   end
else
   errorMsg=['Warning - could not find Block for property table'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  propList=GetPropList(zF,filter)

propList=propfixpt(zF,...
   'GetPropList',...
   filter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  filterList=GetFilterList(zF)

filterList.index=1;
filterList.list=propfixpt(zF,...
   'GetFilterList');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellContent=GetPropCell(zF,zS,propname)

loopObj=zS.Block;

propValue=propfixpt(zF,...
   'GetPropValue',...
   {loopObj},...
   propname);

if length(propValue)>0
   propValue=propValue{1};
else
   propValue='';
end

cellContent.name=propname;
cellContent.value=propValue;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList

list={
   'Default'
   'Mask Properties'
   'Block Limits'
   'Out-Of-Range Errors'
   'All Fixed-Point Properties'
   'Blank 4x4'
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

switch tablename
case 'Default'
   title='%<Name> Block Information';
   colWid=[1 2];
   singleVal=logical(1);
   pnames={
      '%<MaskType>'  
      '%<OutDataType>'
      '%<Resolution>'
      '%<Description>'
   };
   
case 'Mask Properties'
   title='%<Name> Mask Properties';
   colWid=[1 1 1 1];
   singleVal=logical(1);
   pnames={
      '%<MaskType>' '%<OutDataType>'  
      '%<Scaling>' '%<LockScale>'
      '%<RndMeth>' '%<DoSatur>'
      '%<DblOver>' '%<dolog>'
   };
   
case 'Block Limits'
   title='';
   colWid=[1.5 1 1.5 1];
   singleVal=logical(1);
   pnames={
      '%<Name>' '%<OutDataType>'  
      '%<Resolution>' '%<Bias>'
      '%<MinLimit>' '%<MaxLimit>'
      '%<MinValue>' '%<MaxValue>'
   };
      
case 'Out-Of-Range Errors'
   title = '%<Name> Out-Of-Range Errors';
   colWid=[1 2];
   singleVal=logical(1);
   pnames=propfixpt(rptfpmethods,'GetPropList','errors');
   pnames=strcat('%<', pnames, '>');
   
case 'All Fixed-Point Properties'
   title='%<Name> Fixed-Point Information';
   colWid=[1 2];
   singleVal=logical(1);
   pnames=propfixpt(rptfpmethods,'GetPropList','all');
   pnames=strcat('%<', pnames, '>');
   
otherwise %blank 4x4
   title='Title';
   singleVal=logical(0);
   colWid=[1 1 1 1];
   [pnames{1:4,1:4}]=deal('');
end

if singleVal
   defaultAlign='c';
   render='P v';
else
   defaultAlign='l';
   render='v';
end

content=struct('align',defaultAlign,...
   'text',pnames,...
   'border',3,...
   'render',render);

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content,...
   'TitleRender','v');

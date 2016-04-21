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

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:36 $

switch action
case {'GetPresetList' 'GetPresetTable'}
   out=feval(action,varargin{:});
otherwise
   out=tableref(rptproptable,c.zslmethods,'Signal',action,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList

list={'Default'
   'Complete'
   'Compiled Information'
   'Blank 4x4'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

switch tablename
case 'Default'
   title='Signal Information';
   colWid=[1 1.5 1.75 2];
   singleVal=logical(1);
   pnames={'%<Name>' '%<Description>'
      '%<ParentBlock>' '%<CompiledPortDataType>'};
case 'Complete'
   title='Signal Information';
   colWid=[1 2];
   singleVal=logical(1);
   pnames={'%<Name>'
      '%<Description>'
      '%<ParentBlock>'
      '%<ParentSystem>'
      '%<DocumentLink>'
      '%<CompiledPortDataType>'
      '%<CompiledPortWidth>'
      '%<CompiledPortComplexSignal>'};
case    'Compiled Information'
   title='Compiled Information';
   colWid=[1 1.5];
   singleVal=logical(1);
   pnames={'%<Name>'
      '%<CompiledPortDataType>'
      '%<CompiledPortWidth>'
      '%<CompiledPortComplexSignal>'};   
otherwise %blank 4x4
   title='Title';
   singleVal=logical(0);
   colWid=[1 1 1 1];
   [pnames{1:4,1:4}]=deal('');
end

if singleVal
   defaultAlign='c';
else
   defaultAlign='l';
end

content=struct('align',defaultAlign,...
   'text',pnames,...
   'border',3,...
   'render','P v');

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content,...
   'TitleRender','v');
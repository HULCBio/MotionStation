function out=tableref(c,action,varargin)
%TABLEREF interface for generic property table
%   OUT=TABLEREF(CSL_SYS_PROPTABLE,'ACTION')
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:59 $

switch action
case {'GetPresetList' 'GetPresetTable'}
   out=feval(action,varargin{:});
otherwise
   out=tableref(rptproptable,c.zslmethods,'System',action,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList

list={'Default'
   'Mask Properties'
   'System Signals'
   'Print Properties'
   'Blank 4x4'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

defaultRender='P v';
switch tablename
case 'Default'
   title='%<Name> System Information';
   colWid=[1 3 1 1];
   singleVal=logical(1);
   pnames={'%<Name>' '%<Parent>';
      '%<Description>' '%<Tag>';
      '%<Blocks>' '%<LinkStatus>'};
case 'System Signals'
   title='%<Name> System Signals';
   colWid=[1 2];
   singleVal=logical(1);
   pnames={'%<InputSignalNames>'
      '%<OutputSignalNames>'
      '%<CompiledPortWidths>'
      '%<CompiledPortDataTypes>'
      '%<CompiledPortComplexSignals>'};   
case 'Mask Properties'
   title='%<Name> Mask Properties';
   singleVal=logical(1);
   colWid=[1 2];
   pnames={'%<MaskType>'
       '%<Mask>'
      '%<MaskDescription>'   
      '%<MaskHelp>' 
      '%<MaskPrompts>'
      '%<MaskNames>'
      '%<MaskValues>'
      '%<MaskTunableValues>'};   
case 'Print Properties'
   title='%<Name> Print Properties';
   colWid=[1 1.25];
   singleVal=logical(0);   
   pnames={
      '%<PaperPositionMode>',...
         'PaperPosition: %<PaperPosition> %<PaperUnits>';... 
         'PaperType: %<PaperType> %<PaperOrientation>',...
         'PaperSize: %<PaperSize> %<PaperUnits>'
   };
   defaultRender='p:v';
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
   'render',defaultRender);

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content,...
   'TitleRender','v');

if strcmp(tablename,'Print Properties')
   out.TableContent(1,2).render='v';
   out.TableContent(2,2).render='v';
   out.TableContent(2,1).render='v';
end

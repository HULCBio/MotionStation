function out=tableref(c,action,varargin)
%TABLEREF interface for generic property table
%   OUT=TABLEREF(CSL_MDL_PROPTABLE,'ACTION')
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:20 $

switch action
case {'GetPresetList' 'GetPresetTable'}
   out=feval(action,varargin{:});
otherwise
   out=tableref(rptproptable,c.zslmethods,'Model',action,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList

list={'Default'
   'Simulation Parameters'
   'Version Information'
   'RTW Information'
   'Summary (req. RTW)'
   'Blank 4x4'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

switch tablename
case 'Default'
   title='%<Name> Information';
   singleVal=logical(0);
   colWid=[1 1.5];
   pnames={'%<Name>' '%<Description>'
      '%<BlockDiagramType>' '%<FileName>'};
case 'Version Information'
   title='%<Name>  Version Information';
   singleVal=logical(0);
   colWid=[1 1.5];
   pnames={'%<ModelVersion>' '%<ConfigurationManager>'
      '%<Created>' '%<Creator>'
      '%<LastModifiedDate>' '%<LastModifiedBy>'}; 
case 'Summary (req. RTW)'
   title='%<Name> Summary Information';
   singleVal=logical(1);
   colWid=[2 1 2 1];
   pnames={
       '%<NumModelInputs>'           '%<NumModelOutputs>'
       '%<NumVirtualSubsystems>'     '%<NumNonvirtSubsystems>'
       '%<NumNonVirtBlocksInModel>'  '%<NumBlockTypeCounts>'
       '%<NumBlockSignals>'          '%<NumBlockParams>'
       '%<NumZCEvents>'              '%<NumNonsampledZCs>'
       };   
case 'Simulation Parameters'
   title='%<Name> Simulation Parameters';
   singleVal=logical(0);
   colWid=[1 1 1];
   pnames={
       '%<Solver>'       '%<ZeroCross>' '%<StartTime> %<StopTime>'
       '%<RelTol>'       '%<AbsTol>'    '%<Refine>'
       '%<InitialStep>'  '%<FixedStep>' '%<MaxStep>'
   };
case 'RTW Information'
   title='%<Name> Realtime Workshop Information';
   singleVal=logical(1);
   colWid=[2 2 2 1];
   pnames={
       '%<RTWSystemTargetFile>' '%<RTWRetainRTWFile>'
       '%<RTWInlineParameters>' '%<RTWPlaceOutputsASAP>'
       '%<RTWTemplateMakefile>' '%<RTWMakeCommand>'
       '%<RTWGenerateCodeOnly>' '%<RTWUserButton>'
   };
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
   'render','P v',...
   'border',3);

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content,...
   'TitleRender','v');
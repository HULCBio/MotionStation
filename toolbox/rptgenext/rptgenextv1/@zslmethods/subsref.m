function B=subsref(A,S)
%SUBSREF reference fields in the ZSLMETHODS information structure
%   FIELDVAL=SUBSREF(Z,SUBSTRUCT('.','FieldName'))

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:54 $

d=rgstoredata(A);
if isempty(d)
   d=initialize(A,'-noinitialize');
end

B=subsref(d,S);
if isempty(B)
   d=LocGuess(d,S(1).subs);
   rgstoredata(A,d);
   B=subsref(d,S);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function slData=LocGuess(slData,whichField)

if isfield(slData,whichField)
   fieldVal=getfield(slData,whichField);
   if ~isempty(fieldVal)
      return;
   end
else
   fieldVal=[];
end

switch whichField
%--------------current objects----------------------------   
case 'Model'
   slData.Model=bdroot(get_param(0,'CurrentSystem'));
   if ~isempty(slData.Model)
      if ~strcmp(get_param(slData.Model,'blockdiagramtype'),'model')
         mdlList=find_system('SearchDepth',1,'blockdiagramtype','model');
         if isempty(mdlList)
            slData.Model=[];
         else
            slData.Model=mdlList{1};
            set_param(0,'CurrentSystem',slData.Model);
         end
      end
   end
   
case 'System'
   slData=LocGuess(slData,'Model');
   if ~isempty(slData.Model)
      if ~isempty(find_system('SearchDepth',1,...
            'blockdiagramtype','model',...
            'Name',slData.Model))
         slData.System=get_param(0,'CurrentSystem');
      else
         slData.Model=[];
         slData=LocGuess(slData,'Model');
         slData=LocGuess(slData,'System');
      end
   end
   
case 'Block'
   slData=LocGuess(slData,'System');
   if ~isempty(slData.System)
      try
         slData.Block=[slData.System '/' ...
               get_param(slData.System,'CurrentBlock')];
      catch
         slData.System=[];
         slData=LocGuess(slData,'System');
         slData=LocGuess(slData,'Block');
      end
   end
   if ~isempty(find_system(slData.Block,...
           'SearchDepth',0,...
           'Regexp','on',...
           'PhysicalDomain','.'))
       slData.Block=[];
       %Don't report on physmod blocks
   end
   
case 'Signal'
   slData=LocGuess(slData,'System');
   if ~isempty(slData.System)
      try
         signalList=find_system(slData.System,...
            'findall','on',...
            'SearchDepth',1,...
            'type','port',...
            'porttype','outport');      
         if length(signalList)>1
            slData.Signal=signalList(1);
         end
      catch
         slData.System=[];
         slData=LocGuess(slData,'System');
         slData=LocGuess(slData,'Signal');
      end
   end
   
%--------------system looping options---------------------
case 'MdlCurrSys'
   slData.MdlCurrSys={'$current'};
   
case 'SysLoopType'
   slData.SysLoopType='$current';
   
case 'isMask'
   slData.isMask='graphical';
   
case 'isLibrary'
   slData.isLibrary='off';
   
%--------------reported object lists----------------------   
case 'ReportedSystemList'
   slData=LocGuess(slData,'Model');
   slData=LocGuess(slData,'System');
   slData=LocGuess(slData,'MdlCurrSys');
   slData=LocGuess(slData,'SysLoopType');
   slData=LocGuess(slData,'isMask');
   slData=LocGuess(slData,'isLibrary');
   
   slData.ReportedSystemList=LocReportedSystems(slData);
   
case 'ReportedBlockList'
   slData=LocGuess(slData,'ReportedSystemList');
   bList=find_system(slData.ReportedSystemList,...
      'SearchDepth',1,...
      'type','block');
   %do we want any post-processing on the block list?
   
   slData.ReportedBlockList = LocRemovePhysmod(bList);

   %slData.ReportedBlockList=unique(bList);   
case 'ReportedSignalList'
   %get outports of all reported blocks
   slData=LocGuess(slData,'ReportedSystemList');
   sList=find_system(slData.ReportedSystemList,...
      'findall','on',...
      'SearchDepth',1,...
      'type','port',...
      'porttype','outport');
   %do we want any post-processing on the block list?
   slData.ReportedSignalList=unique(sList);
   
%----------------------- TLC stuff --------------

% case 'TlcContext'
%    %The TLC context handle of the current model
%    slData.TlcContext=[];
%    if strcmp(get_param(0,'RtwLicensed'),'on')
%       slData=LocGuess(slData,'Model');
%       if ~isempty(slData.Model)
%          slData.TlcContext=tlccontext(zslmethods,slData.Model);
%       end
%    end
      
%----------------------------------
case 'WordAllList'
   slData=LocGuess(slData,'ReportedBlockList');
   slData.WordAllList=wordlist(zslmethods,...
      'LocGetWordList',...
      slData.ReportedBlockList);
   
case 'WordFunctionList'
   slData=LocGuess(slData,'WordAllList');
   slData.WordFunctionList=wordlist(zslmethods,...
      'LocGetFunctionList',...
      slData.WordAllList);
   
case 'WordVariableList'
   slData=LocGuess(slData,'WordAllList');
   slData.WordVariableList=wordlist(zslmethods,...
      'LocGetVariableList',...
      slData.WordAllList);   
   
%----------Cleanup Information ------------
case 'PreRunOpenModels'
   slData.PreRunOpenModels=find_system('SearchDepth',1,...
      'type','block_diagram',...
      'blockdiagramtype','model');
   
% case 'PreRunOpenTlcContext'
%    try
%       allContext=tlc('list');
%    catch
%       allContext=nan;
%    end
%    slData.PreRunOpenTlcContext=allContext;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rsl=LocReportedSystems(slData)

%Valid MdlCurrSys values (cell array - may be more than one)
% $current - current system
% $top - top-level system
% string - system name (must be full path name)

%Valid SysLoopType values
% $all - all systems in model
% $current - systems defined in MdlCurrSys
% $currentAbove - systems in MdlCurrSys + parents
% $currentBelow - systems in MdlCurrSys + children

if isempty(slData.MdlCurrSys) | isempty(slData.Model)
   rsl={};
else   
   %Current System List
   csl=unique(strrep(...
      strrep(slData.MdlCurrSys,...
      '$current',slData.System),...
      '$top',slData.Model));
   
   switch slData.SysLoopType
   case '$current'
      rsl=csl;
      libPostProcess=0; 
   case '$currentAbove'
      rsl={};
      for i=1:length(csl)
         rsl=[rsl;LocTraverseUp(csl(i))];
      end
      rsl=unique(rsl);
      libPostProcess=0; 
   otherwise %$all and $currentBelow
      if strcmp(slData.SysLoopType,'$all')
         startSystem={slData.Model};
      else
         startSystem=csl;
      end
      
      switch slData.isMask
      case 'none'
         maskSwitch='none';
         maskFind={'mask','off'};
      case 'functional'
         maskSwitch='functional';
         maskFind={'MaskHelp','',...
               'MaskDescription','',...
               'MaskVariables',''};
      case {'all' 'on' logical(1)}
         maskSwitch='all';
         maskFind={'type','block'};
      otherwise
         %{'graphical' 'off' logical(0)}
         maskSwitch='graphical';
         maskFind={'MaskHelp','',...
               'MaskDescription','',...
               'MaskVariables','',...
               'MaskInitialization',''};
      end
         
      switch slData.isLibrary
      case {'on' logical(1)}
         libSwitch='on';
         libPostProcess=0;
      case 'unique'
         libSwitch='on';
         libPostProcess=1;
      otherwise
         %{'off' logical(0)}
         libSwitch='off';
         libPostProcess=-1;
      end
      
      findCell={'LookUnderMasks',maskSwitch,...
            'FollowLinks',libSwitch,...
            'blocktype','SubSystem'};
      
      rsl=union(find_system(startSystem,findCell{:},maskFind{:}),...
         startSystem);
      
      if libPostProcess~=0 
         rsl=LocFilterLibraries(rsl,libPostProcess);
      else
         %force column
         rsl=rsl(:);
      end
   end %switch looptype
   
   rsl=excludesystems(zslmethods,rsl);
   
end %if there is no current system or model


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sList=LocTraverseUp(sList)

sParent=get_param(sList{end},'Parent');
if ~isempty(sParent)
   sList=[sList;{sParent}];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uniqueList=LocFilterLibraries(allList,actionType);
%actionType==1 get unique libraries
%actionType==-1 eliminate all libraries

blockList=find_system(allList,...
   'SearchDepth',0,...
   'type','block');
unlinkedBlocks=find_system(blockList,...
   'SearchDepth',0,...
   'LinkStatus','none');
linkedBlocks=setdiff(blockList,unlinkedBlocks);

if ~isempty(linkedBlocks)
   modelList=setdiff(allList,blockList);
   if actionType>0
      refBlocks=getparam(zslmethods,linkedBlocks,'referenceblock');
      [uniqRefBlocks,uniqIndex]=unique(refBlocks);
      
      uniqLinkedBlocks=linkedBlocks(uniqIndex);
      
      uniqueList=[modelList(:)
         unlinkedBlocks(:)
         uniqLinkedBlocks(:)];
   else
      uniqueList=[modelList(:)
         unlinkedBlocks(:)];
   end
else
   uniqueList=allList(:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bList = LocRemovePhysmod(bList)

pmBlocks = find_system(bList,...
    'SearchDepth',0,...
    'Regexp','on',...
    'PhysicalDomain','.');

if ~isempty(pmBlocks)
   %setdiff also performs unique
   bList = setdiff(bList,pmBlocks);
else
   bList = unique(bList);
end

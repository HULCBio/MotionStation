function out=propmodel(z,action,varargin)
%PROPMODEL gets parameters from Simulink models
%   ALLLISTS=PROPMODEL(ZSLMETHODS,'GetFilterList')
%   LISTPARAMS=PROPMODEL(ZSLMETHODS,'GetPropList','ListName')
%      Where 'ListName' is any of the valid property list
%      ID's from 'GetFilterList'.
%   PROPVALUE=PROPMODEL(ZSLMETHODS,'GetPropValue',MDLLIST,'PropName')

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:47 $

switch action
case 'GetFilterList'
   out={'main' 'Main Properties'
      'all' 'All Properties'
      'version' 'Version History Properties'
      'sim' 'Simulation Properties'
      'ext','Ext Mode'
      'paper' 'Print Properties'};
   
   if strcmp(get_param(0,'rtwlicensed'),'on');
      out(end+1:end+2,:)={'rtw' 'Realtime Workshop Properties';
         'rtwsummary' 'Model Summary (req RTW)'};
   end
case 'GetPropList'
   %varargin{1} should be a filter from GetFilterList
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   Models=varargin{1};
   
   switch Property
   case {'Blocks' 'Lines' 'Signals' 'PaperSize' 'PaperPosition'}
      out=propsystem(z,action,Models,Property);
   case {'NameLinked'}
      out=feval(['Loc' Property],z,Models);
   case LocGetPropList('rtwsummary')
      out=LocRtwSummary(z,Models,Property);
   otherwise
      out=getparam(z,Models,Property);
   end %case Property
end %primary case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'all'
   list=LocAllProps;
   rtwList=LocGetPropList('rtwsummary');
   list=[list ; rtwList];
case 'sim'
   list={'StartTime'
    'StopTime'
    'Solver'
    'RelTol'
    'AbsTol'
    'Refine'
    'MaxStep'
    'InitialStep'
    'FixedStep'
    'MaxOrder'
    'OutputOption'
    'OutputTimes'
    'LoadExternalInput'
    'ExternalInput'
    'SaveTime'
    'TimeSaveName'
    'SaveState'
    'StateSaveName'
    'SaveOutput'
    'OutputSaveName'
    'LoadInitialState'
    'InitialState'
    'SaveFinalState'
    'FinalStateName'
    'Decimation'
    'AlgebraicLoopMsg'
    'MinStepSizeMsg'
    'UnconnectedInputMsg'
    'UnconnectedOutputMsg'
    'UnconnectedLineMsg'
    'ConsistencyChecking'
    'ForceConsistencyChecking'
    'ZeroCross'};
case 'paper'
   list=LocFilterList(LocAllProps,'Paper');
case 'ext'
   list=LocFilterList(LocAllProps,'ExtMode');   
case 'rtw'
   list=LocFilterList(LocAllProps,'RTW');
case 'fcn'
   list=LocFilterList(LocAllProps,'Fcn',logical(1));
case 'main'
    list={
        'Name'
        'FileName'
        'Created'
        'Creator'
        'Description'
        'Tag'
        'Version'
        'Blocks'
        'Signals'
    };
case 'version'
    list={
        'Created'
        'Creator'
        'UpdateHistory'
        'ModifiedByFormat'
        'ModifiedBy'
        'LastModifiedBy'
        'ModifiedDateFormat'
        'ModifiedDate'
        'LastModifiedDate'
        'ModifiedComment'
        'ModifiedHistory'
        'ModelVersionFormat'
        'ModelVersion'
        'ConfigurationManager'
    };
case 'rtwsummary'
    list={
        'NumModelInputs'
        'NumModelOutputs'
        'NumNonVirtBlocksInModel'
        'NumBlockTypeCounts'
        'NumVirtualSubsystems'
        'NumNonvirtSubsystems'
        'DirectFeedthrough'
        'NumContStates'
        'ZCFindingDisabled'
        'NumNonsampledZCs' 
        'NumZCEvents' 
        'NumDataStoreElements' 
        'NumBlockSignals'
        'NumBlockParams' 
        'NumAlgebraicLoops' 
        'InvariantConstants'
    };      
otherwise
   list={};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function value=LocNameLinked(z,obj)

objName=getparam(z,obj,'Name');

r=rptcomponent;
linkComp=r.comps.cfrlink;
linkComp.att.LinkType='Link';

numObj=length(obj);
value=cell(numObj,1);
for i=numObj:-1:1
   if ~isempty(objName{i})
      linkComp.att.LinkID=linkid(z,obj{i},'mdl');
      linkComp.att.LinkText=objName{i};
      value{i}=runcomponent(linkComp,0);
   else
      value{i}='&nbsp;';
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocRtwSummary(z,mdl,prop);

for i=length(mdl):-1:1
    fid = get_rtw_fid(z,mdl{i});
    if fid>0
        out{i,1}=locRtwParser(fid,prop);
        fclose(fid);
    else
        out{i,1}='N/A';
    end
end

%This code will test for invalid RTW properties.
%p=propmodel(z,'GetPropList','rtwsummary');v={};for i=length(p):-1:1;v(i)=propmodel(z,'GetPropValue',{z.Model},p{i});end;[p,v']


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Utility functions used by other functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filtered=LocFilterList(unfiltered,spec,compareEnd)
%LocFilterList searches "unfiltered" for the string "spec"
%if compareEnd is false (the default), it searches for spec
%in the prefix.  If true, it looks in the suffix.  

listBlock=strvcat(unfiltered{:});
if nargin>2 & compareEnd
   listBlock=strjust(listBlock(:,end:-1:1),'left');
   spec=spec(:,end:-1:1);
end

okIndices=strmatch(spec,listBlock);
filtered=unfiltered(okIndices);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function propNames=LocAllProps
%LocAllProps returns all properties for a system

persistent ZSLMETHODS_ALL_MODEL_PROPERTIES

if isempty(ZSLMETHODS_ALL_MODEL_PROPERTIES)
   [modname,sysname]=tempmodel(zslmethods);
   
   allProps=get_param(modname,'objectparameters');
   propNames=fieldnames(allProps);
   i=1;
   while i<=length(propNames)
       if any(strcmp(subsref(allProps,substruct('.',propNames{i},'.','Attributes')),'write-only'));
           %not a readable property.  Remove from list
           propNames=[propNames(1:i-1);propNames(i+1:end)];
       else
           i=i+1;
       end
   end
   ZSLMETHODS_ALL_MODEL_PROPERTIES=propNames;
else
    propNames=ZSLMETHODS_ALL_MODEL_PROPERTIES;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pVal = locRtwParser(fid,propName)

pVal = 'N/A';
lenPropName = length(propName);
while 1
    s = fgetl(fid);
    if ~ischar(s)
        break;
    else
        s=trimString(s);
        if strncmpi(s,propName,lenPropName)
            pVal=trimString(s(lenPropName+1:end));
            break;
        end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=trimString(s)
%acts like deblank, but removes trailing and leading spaces

[r,c] = find( (s~=0) & ~isspace(s) );
if isempty(c),
    s = s([]);
else
    s = s(:,min(c):max(c));
end

function [funcName,inData,outData,obsData,changeNeeded,earlyReturn] = reconcile_function_io(objectId,dryRun)

% A super intelligent auto-populator of data from function prototypes
%  
%	Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.9 $  $Date: 2004/04/15 00:59:04 $

% if dryRun is 1, then we just go thru the motions
% of doing everything without actually creating or
% munging the data. Useful when we want to detect change
% and throw errors. For example, during simstart, emlblock io
% cannot be changed. an early return flag is set to 1 
% if we there is an error
if(nargin<2)
    dryRun = 0;
end
inData=[];
outData=[];
obsData=[];
funcName = '';
changeNeeded = 0;
earlyReturn = 1;
try,
   if(is_eml_chart(objectId) & ~dryRun)
        machineId = sf('get',objectId,'.machine');
        machineName = sf('get',machineId,'.name');
   end
   [funcName,inData,outData,obsData,changeNeeded] = try_reconcile_function_io(objectId,dryRun);
   earlyReturn= 0;
catch,
   disp('Error trying to reconcile function io.');
   disp(lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [funcName,inData,outData,obsData,changeNeeded] = try_reconcile_function_io(objectId,dryRun)

inData=[];
outData=[];
obsData=[];
funcName = '';

funcLabel = get_function_prototype(objectId);

[funcData,funcInData,funcOutData] = get_function_data(objectId);
funcIOData = [funcInData,funcOutData];

[funcName,inDataNames,outDataNames] = parse_function_label_for_io(funcLabel);
if(~isempty(funcName))
   funcName = funcName{1};
end

for i=1:length(inDataNames)
   % try to find something with the same name. if you find it
   % set its scope and port number
   inData(i).name = inDataNames{i};
   inDataId = sf('find',funcData,'data.name',inData(i).name);
   if(~isempty(inDataId))
      inData(i).id = inDataId;
      funcData = vset(funcData,'-',inDataId);
   else
      inData(i).id = 0;
   end
end

numOutput = 0;
if(~isempty(sf('get',objectId,'state.id')))
    % Graphical Functions have at most 1 output
    numOutput = min(length(outDataNames), 1);
elseif(~isempty(sf('get',objectId,'chart.id')))
    numOutput = length(outDataNames);
end
    
for i=1:numOutput
   % try to find something with the same name. if you find it
   % set its scope and port number
   outData(i).name = outDataNames{i};
   outDataId = sf('find',funcData,'data.name',outData(i).name);
   if(~isempty(outDataId))
      outData(i).id = outDataId;
      funcData = vset(funcData,'-',outDataId);
   else
      outData(i).id = 0;
   end
end

allResolvedData = [];
if(~isempty(inData))
   allResolvedData = [inData.id];
end
if(~isempty(outData))
    allResolvedData = [allResolvedData,outData.id];
end

obsInData = vset(funcInData,'-',allResolvedData);
obsOutData = vset(funcOutData,'-',allResolvedData);

for i=1:length(inData)
  if(isempty(obsInData))
    break;
  end
  if(inData(i).id==0)
    inData(i).id = obsInData(1);
    obsInData(1)=[];
    end
end

for i=1:length(outData)
  if(isempty(obsOutData))
    break;
  end
  if(outData(i).id==0)
    outData(i).id = obsOutData(1);
    obsOutData(1)=[];
  end
end

obsData = [obsInData,obsOutData];
set_function_name(objectId,funcName);

[changeNeeded, inData, outData] = rearrange_data_if_needed(objectId,inData,outData,obsData,dryRun);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function funcLabel = get_function_prototype(objectId)

if(~isempty(sf('get',objectId,'state.id')))
    funcLabel = sf('get',objectId,'state.labelString');
elseif(~isempty(sf('get',objectId,'chart.id')))
    funcLabel = eml_man('get_eml_prototype',objectId);
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [funcData,funcInData,funcOutData] = get_function_data(objectId)

funcData = sf('DataOf',objectId);

if(~isempty(sf('get',objectId,'state.id')))
    funcInData = sf('find',funcData,'data.scope','FUNCTION_INPUT_DATA');
    funcOutData = sf('find',funcData,'data.scope','FUNCTION_OUTPUT_DATA');
elseif(~isempty(sf('get',objectId,'chart.id')))
    funcInData = sf('find',funcData,'data.scope','INPUT_DATA');
    funcInData = [funcInData sf('find',funcData,'data.scope','PARAMETER_DATA')];
    funcOutData = sf('find',funcData,'data.scope','OUTPUT_DATA');
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_function_name(objectId,funcName)
if(~isempty(sf('get',objectId,'state.id')))
    sf('set',objectId,'state.name',funcName);
elseif(~isempty(sf('get',objectId,'chart.id')))
    % Don't change block name ever
    % set_param(chart2block(objectId),'Name',funcName);
end
return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [changeNeeded, inData, outData] = rearrange_data_if_needed(objectId,inData,outData,obsData,dryRun)

changeNeeded = 0;
if(~isempty(sf('get',objectId,'chart.id')))
    if ~isempty(obsData)
        if ~dryRun
            sf('delete',obsData);
        end
        changeNeeded = 1;
    end
        
    [needChange, inData] = reconcile_data_scopes_names(inData,objectId,'INPUT_DATA',dryRun);
    changeNeeded = changeNeeded + needChange;
        
    [needChange, outData] = reconcile_data_scopes_names(outData,objectId,'OUTPUT_DATA',dryRun);
    changeNeeded = changeNeeded + needChange;
    
    nInData = length(inData);
    if nInData > 1 && sf('EmlChartChgInputSeq',[inData.id], [1:nInData], 1) % Check if change needed only
        if ~dryRun
            sf('EmlChartChgInputSeq',[inData.id],[1:nInData]);
        end
        changeNeeded = 1;
    end
    
    if (changeNeeded & ~dryRun)
        sf('NotifyObjectChildrenChanged', objectId);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [changeNeeded, inData] = reconcile_data_scopes_names(inData,objectId,scopeStr,dryRun)

changeNeeded = 0;
for i=1:length(inData)
   if(inData(i).id)
      if(~strcmp(sf('get',inData(i).id,'data.name'),inData(i).name))
         if(~dryRun)
            sf('set',inData(i).id,'data.name',inData(i).name);
         end
         changeNeeded = 1;
      end
      if(isempty(sf('find',inData(i).id,'data.scope',scopeStr))) && ...
         ~(strcmp(scopeStr, 'INPUT_DATA') && ~isempty(sf('find',inData(i).id,'data.scope','PARAMETER_DATA')))
         if(~dryRun)
            sf('set',inData(i).id,'data.scope',scopeStr);
         end
         changeNeeded = 1;
      end
   else
      if(~dryRun)
        inData(i).id = new_data(objectId,scopeStr,inData(i).name);
      end
      changeNeeded = 1;
   end
   
   if ~strcmp(scopeStr, 'INPUT_DATA') % Chart input/param data are handled differently
       if(length(inData)>1 && inData(i).id~=0 && sf('ScopeIndex',inData(i).id)~=i)
           if ~dryRun
               sf('ChgPortIndTo',inData(i).id,i);
           end
           changeNeeded = 1;
       end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [funcName,inData,outData] = parse_function_label_for_io(funcLabel)

funcLabel = regexprep(funcLabel, '^\s*', '', 'once');
funcLabel = function_prototype_utils('filter_out_line_cont', funcLabel);

newLineLoc = find(funcLabel==10);
if(~isempty(newLineLoc))
   funcLabel = funcLabel(1:newLineLoc);
end

%rightParenLoc = find(funcLabel==sprintf(')'));
%if(~isempty(rightParenLoc))
%   funcLabel = funcLabel(1:rightParenLoc);
%end

equalLoc = find(funcLabel=='=');
if(isempty(equalLoc))
   lhsStrCells = [];
   rhsStrCells = regexp(funcLabel, '[a-zA-Z]\w*', 'match');
else
   lhsStrCells = regexp(funcLabel(1:equalLoc), '[a-zA-Z]\w*', 'match');
   rhsStrCells = regexp(funcLabel(equalLoc:end), '[a-zA-Z]\w*', 'match');
end

funcName = '';
inData = [];
outData = [];

switch(length(lhsStrCells))
case 0
   % do nothing
otherwise
   %outData = lhsStrCells(1);
   outData = lhsStrCells;
end

switch(length(rhsStrCells))
case 0
   % do nothing
case 1
   funcName = rhsStrCells(1);
otherwise
   funcName = rhsStrCells(1);
   inData = rhsStrCells(2:end);
end

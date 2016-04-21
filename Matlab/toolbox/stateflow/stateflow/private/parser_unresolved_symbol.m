function throwError = parser_unresolved_symbol(machineId,...
                                               chartId,...
                                               targetId,...
                                               allowedSymbolsInfo,...
                                               exportedFunctionsInfo)
% parser_unresolved_symbol - handle undeclared symbol errors found by SF parser

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.23.2.1 $  $Date: 2004/04/15 00:59:00 $


[dataSymbolArray,...
 eventSymbolArray,...
 functionSymbolArray,...
 nonRTWdataArray,...
 nonRTWFunctionArray]= sf('UnresolvedSymbolsIn',machineId,chartId,targetId);

throwError = 0;

%% For data and events, we uniquefy based on name and tentative-parent
dataSymbolArray = uniquefy_error_struct_array(dataSymbolArray,'parent');
eventSymbolArray = uniquefy_error_struct_array(eventSymbolArray,'parent');
functionSymbolArray = uniquefy_error_struct_array(functionSymbolArray,'parent');

dataSymbolArray = rem_unres_event_syms_in_data(dataSymbolArray,eventSymbolArray);
[dataSymbolArray,aliasedDataSymbolArray] = rem_res_event_syms_in_data(dataSymbolArray);

%% For nonRTW data/fcns, we uniquefy based on name and context 
%% (state or trans referring to it)
nonRTWdataArray = uniquefy_error_struct_array(nonRTWdataArray,'context');
nonRTWFunctionArray = uniquefy_error_struct_array(nonRTWFunctionArray,'context');

if(~isempty(eventSymbolArray) |...
   ~isempty(nonRTWdataArray)  |...
   ~isempty(nonRTWFunctionArray) |...
   ~isempty(aliasedDataSymbolArray))
   throw_errors(eventSymbolArray,'Unresolved event');
   throw_errors(nonRTWdataArray, 'RTW incompatible MATLAB data');
   throw_errors(nonRTWFunctionArray,'RTW incompatible MATLAB function');
   throw_errors(aliasedDataSymbolArray,'Unresolved data shadowed by an event of the same name');
   throwError = 1;
end


functionSymbolArray = filter_unresolved_symbols(targetId, functionSymbolArray,exportedFunctionsInfo);
if(~isempty(functionSymbolArray))
   throwError = 1;
   throw_errors(functionSymbolArray,'Unresolved function');
end

dataSymbolArray = filter_unresolved_symbols(targetId,dataSymbolArray,allowedSymbolsInfo);
if(~isempty(dataSymbolArray))
   throwError = 1;
   throw_errors(dataSymbolArray,'Unresolved data');
end

% Just before saving them on the chart, remove orphans
% since they cannot be created by symbol wizard
dataSymbolArray = remove_orphans(dataSymbolArray);
eventSymbolArray = remove_orphans(eventSymbolArray);

sf('set',chartId,'chart.unresolved.data',dataSymbolArray);
sf('set',chartId,'chart.unresolved.events',eventSymbolArray);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dataSymbolArray,aliasedDataSymbolArray] = rem_res_event_syms_in_data(dataSymbolArray)
   aliasedDataSymbolArray = [];
   if(isempty(dataSymbolArray))
      return;
   end
   % Remove all unresolved data symbols which have a corresponding
   % unresolved event symbol with the same name and parent
   firstTime = 1;
   for i=length(dataSymbolArray):-1:1
      parentId = dataSymbolArray(i).tentativeParentId;
      symbolName = dataSymbolArray(i).symbolName;
      if(parentId~=0 & ...
         ~isempty(sf('find',sf('EventsOf',parentId),'event.name',symbolName)))
         %% We found an event with the same name at the same parent
         if(firstTime)
            aliasedDataSymbolArray = dataSymbolArray(i);
            firstTime = 0;
         else
            aliasedDataSymbolArray(end+1) = dataSymbolArray(i);
         end
         dataSymbolArray(i) = [];
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataSymbolArray = rem_unres_event_syms_in_data(dataSymbolArray,eventSymbolArray)
   if(isempty(dataSymbolArray) | isempty(eventSymbolArray))
      return;
   end
   % Remove all unresolved data symbols which have a corresponding
   % unresolved event symbol with the same name and parent
   for i=length(dataSymbolArray):-1:1
      m1 = strcmp({eventSymbolArray.symbolName},dataSymbolArray(i).symbolName);
      if(any(m1))
         m2 = [eventSymbolArray(m1).tentativeParentId]==dataSymbolArray(i).tentativeParentId;
         if(any(m2))
            dataSymbolArray(i) = [];
         end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorStructArray = remove_orphans(errorStructArray) 
   for i=length(errorStructArray):-1:1
      if(errorStructArray(i).tentativeParentId==0) 
         errorStructArray(i) = [];
      end
   end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function errorStructArray = uniquefy_error_struct_array(errorStructArray,filterField)
   symbolNamesWithTypes = cell(1,length(errorStructArray));
   %% repeating for-loops in two cases is faster than
   %% switching inside a single for-loop. This is also
   %% better than passing in a filter field name and doing
   %% an eval() inside the forloop.
   switch(filterField)
   case 'context'
      for i=1:length(errorStructArray)
         symbolNamesWithTypes{i} = sprintf('%s %d',errorStructArray(i).symbolName,errorStructArray(i).contextObjectId);
      end
   case 'parent'
      for i=1:length(errorStructArray)
         symbolNamesWithTypes{i} = sprintf('%s %d',errorStructArray(i).symbolName,errorStructArray(i).tentativeParentId);
      end
   end
   [dummy,indices] = unique(symbolNamesWithTypes); % i is vector of indices of non-redundant messages
   errorStructArray = errorStructArray(indices);   % delete redundant entrie

function throw_errors(errorStructArray,symbolTypeStr)
   % construct actual error messages
   for i = 1:length(errorStructArray)
      errorStruct = errorStructArray(i);
      objectId = errorStruct.contextObjectId;
      symbolName = errorStruct.symbolName;
      if(~isempty(sf('get',objectId,'state.id')))
         objectType = 'state';
         objectName = sf('get',objectId,'state.name');
      elseif(~isempty(sf('get',objectId,'transition.id')))
         objectType = 'transition';
         objectName = sf('get',objectId,'transition.labelString');
      else
         objectType = '<>';
         objectName = '<>';
      end   
      
      buf = sprintf('%s ''%s'' in %s %s (#%d)\n',symbolTypeStr,symbolName,objectType,objectName,objectId);
      construct_error( objectId, 'Parse', buf, 0 );
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = filter_unresolved_symbols(targetId, errorStructArray,allowedSymbolsInfo)
   
	result = [];
	if(allowedSymbolsInfo.ignoreUnresolvedSymbols)
        return;
	end
	
    if(~isempty(allowedSymbolsInfo.symbols))
        % eliminate from errorStructArray any symbols that appear on allowedSymbols list.
        for i = length(errorStructArray):-1:1
            if any(strcmp(allowedSymbolsInfo.symbols,errorStructArray(i).symbolName)~=0)
                errorStructArray(i) = [];
            end
        end
    end
	result = errorStructArray;


function [out1,out2] = fnd_objprop(in1),
%[OUT1, OUT2] = FND_OBJPROP( IN1 ) Function to perform initial sort and build object 
%  properties from a vector of Stateflow handles.
%  Note:   This will require modification after new object types are added.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.18.2.1 $  $Date: 2004/04/15 00:57:52 $

   [out1,out2] = i_find_object_properties(in1);

function [displayCellArray,sortedHandles] = i_find_object_properties(unsortedHandles),


% Separate the handles by class:

% use single line later (AWAITING BUG FIX)
%[dataHandles,eventHandles,stateHandles,transHandles,junctionHandles] = ...
%  sf('get',unsortedHandles,'data.id','event.id','state.id','transition.id','junction.id');
 
 
 dataHandles = sf('get',unsortedHandles,'data.id');
 eventHandles = sf('get',unsortedHandles,'event.id');
 stateHandles = sf('get',unsortedHandles,'state.id');
 transHandles = sf('get',unsortedHandles,'transition.id');
 junctionHandles = sf('get',unsortedHandles,'junction.id');
 targetHandles = sf('get',unsortedHandles,'target.id');


displayCellArray = {'','','','','',''};
sortedHandles = [];


%
% Find the isa values for objects and store them in a structure:
%

Isa.chart =  sf('get','default','chart.isa');
Isa.junct =  sf('get','default','junction.isa');
Isa.tran =  sf('get','default','transition.isa');
Isa.data =  sf('get','default','data.isa');
Isa.event =  sf('get','default','event.isa');
Isa.target =  sf('get','default','target.isa');
Isa.machine =  sf('get','default','machine.isa');
Isa.state =  sf('get','default','state.isa'); % -JRT
%Isa.note =  sf('get','default','note.isa');




%
% Display fields for data
%

if ~isempty(dataHandles)

  numData = length(dataHandles);

  % Data type display

  dataType = char(ones(numData,1)*'Data');
  dataNames = sf('get',dataHandles,'data.name');

  emptyCol = char(32*ones(numData,1));

  % Find the parents                                                      
                                                                          
  dataParentHandles = sf('get', dataHandles,'.linkNode.parent');  
  dataParentString =  i_find_full_path(dataParentHandles,Isa);    

	% 
	% Added code for data chartname management -JRT  
	%
	dataChartHandles = zeros(size(dataParentHandles)); % preallocate
	for i=1:numData, 
		parent = dataParentHandles(i);
		parentIsa = sf('get', parent, '.isa');

		switch(parentIsa),
			case Isa.chart, dataChartHandles(i) = parent;
			case Isa.state, dataChartHandles(i) = sf('get', parent, '.chart');
			otherwise, % rien.
		end;
	end;
	dataChartNames = i_find_chart(dataChartHandles);
  
  %
  % Find the sorted ordering   (for now just set to sequntial)
  %

  [notUsed,ordering] = sortrows(dataNames);


  displayCellArray{1} = strrows(displayCellArray{1},dataType(ordering,:));
  displayCellArray{2} = strrows(displayCellArray{2},dataNames(ordering,:));
  displayCellArray{3} = strrows(displayCellArray{3},dataChartNames(ordering, :)); % -JRT
  displayCellArray{4} = strrows(displayCellArray{4},dataParentString(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},emptyCol);
  displayCellArray{6} = strrows(displayCellArray{6},emptyCol);

  sortedHandles = [sortedHandles; dataHandles(ordering)];


end

%
% Display fields for events
%

if ~isempty(eventHandles)

  numEvents = length(eventHandles);

  % Event type display

  eventType = char(ones(numEvents,1)*'Event');
  eventNames = sf('get',eventHandles,'event.name');

  emptyCol = char(32*ones(numEvents,1));

  % Find the parents                                                      
                                                                          
  eventParentHandles = sf('get', eventHandles,'.linkNode.parent');  
  eventParentString =  i_find_full_path(eventParentHandles,Isa);    
                                                                          
	% 
	% Added code for event chartname management -JRT  
	%
	eventChartHandles = zeros(size(eventParentHandles));
	for i=1:numEvents, 
		parent = eventParentHandles(i);
		parentIsa = sf('get', parent, '.isa');

		switch(parentIsa),
			case Isa.chart, eventChartHandles(i) = parent;
			case Isa.state, eventChartHandles(i) = sf('get', parent, '.chart');
			otherwise, % nada
		end;
	end;
  	eventChartNames = i_find_chart(eventChartHandles);
   
  %
  % Find the sorted ordering   (for now just set to sequntial)
  %

  [notUsed,ordering] = sortrows(eventNames);

  displayCellArray{1} = strrows(displayCellArray{1},eventType(ordering,:));
  displayCellArray{2} = strrows(displayCellArray{2},eventNames(ordering,:));
  displayCellArray{3} = strrows(displayCellArray{3},eventChartNames(ordering,:)); % -JRT
  displayCellArray{4} = strrows(displayCellArray{4},eventParentString(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},emptyCol);
  displayCellArray{6} = strrows(displayCellArray{6},emptyCol);

  sortedHandles = [sortedHandles; eventHandles(ordering)];


end

%
% Display fields for junctions
%

if ~isempty(junctionHandles)

  % Type contains label string

  junctionType = sf('get', junctionHandles,'.labelString');
  if length(junctionHandles)~=length(junctionType),
     junctionTypeCompleteName = ...
       char(ones(length(junctionHandles),1)*stradd('Junct(',junctionType,')'));
  else
     junctionTypeCompleteName = stradd('Junct(',junctionType,')');
  end

  % No entries for label

  % Chart

  junctionChartHandles = sf('get', junctionHandles,'.chart');
  junctionChartNames = i_find_chart(junctionChartHandles);

  % Find the parents

  junctionParentHandles = sf('get', junctionHandles,'.linkNode.parent');
  junctionParentString =  i_find_full_path(junctionParentHandles,Isa);

  % Augment the output cell array:

  numJunctions = length(junctionHandles);
  emptyCol = char(32*ones(numJunctions,1));

  %
  % Find the sorted ordering (for now just set to sequntial)
  %

  sortStringMat = lower([junctionType ...
    junctionChartNames(:,1:min([end 4]))  junctionParentString(:,1:min([end 4]))]);

  [notUsed,ordering] = sortrows(sortStringMat);

  %displayCellArray = [displayCellArray; ...
  %  junctionTypeCell(ordering) emptyCol junctionChartCell(ordering) ...
  %  junctionParentCell(ordering) emptyCol emptyCol];

  displayCellArray{1} = strrows(displayCellArray{1},junctionTypeCompleteName(ordering,:));
  displayCellArray{2} = strrows(displayCellArray{2},emptyCol);
  displayCellArray{3} = strrows(displayCellArray{3},junctionChartNames(ordering,:));
  displayCellArray{4} = strrows(displayCellArray{4},junctionParentString(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},emptyCol);
  displayCellArray{6} = strrows(displayCellArray{6},emptyCol);


  sortedHandles = [sortedHandles; junctionHandles(ordering)];

end

%
% Display fields for states
%

if ~isempty(stateHandles)
  
  numStates = length(stateHandles);
  
  % Find the type

  stateType = sf('get',stateHandles,'.type');
  orIndex = find(~stateType);
  andIndex = find(stateType);
  stateType(orIndex) = 'O';
  stateType(andIndex) = 'A';
  stateType = char(stateType);

  stateCompleteType = stradd('State(',stateType,')');

  % Find the label strings and use '|' to separate lines

  stateLabel = sf('get',stateHandles,'.labelString');
  stateLabelString = i_combine_lines(stateLabel);

  % Chart

  stateChartHandles = sf('get', stateHandles,'.chart');
  stateChartNames = i_find_chart(stateChartHandles);

  % Find the parents

  stateParentHandles = sf('get', stateHandles,'.treeNode.parent');
  stateParentMat =  i_find_full_path(stateParentHandles,Isa);

  % Augment the output cell array:

  emptyCol = char(32*ones(numStates,1));

  %
  % Find the sorted ordering   (for now just set to sequntial)
  %

  sortStringMat = lower([stateType ...
    stateLabelString(:,1:min([end 4]))  stateChartNames(:,1:min([end 4]))]);

  [notUsed,ordering] = sortrows(sortStringMat);

  %displayCellArray = [displayCellArray; ...
  %  stateTypeCell(ordering) stateLabelCell(ordering) stateChartCell(ordering) ...
  %  stateParentCell(ordering) emptyCol emptyCol];

  displayCellArray{1} = strrows(displayCellArray{1},stateCompleteType(ordering,:));
  displayCellArray{2} = strrows(displayCellArray{2},stateLabelString(ordering,:));
  displayCellArray{3} = strrows(displayCellArray{3},stateChartNames(ordering,:));
  displayCellArray{4} = strrows(displayCellArray{4},stateParentMat(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},emptyCol);
  displayCellArray{6} = strrows(displayCellArray{6},emptyCol);

  sortedHandles = [sortedHandles; stateHandles(ordering)];

end

%
% Display fields for target
%

if ~isempty(targetHandles)

  numTarget = length(targetHandles);

  % target type display

  targetType = char(ones(numTarget,1)*'Target');
  targetNames = sf('get',targetHandles,'target.name');

  emptyCol = char(32*ones(numTarget,1));

  % Find the parents                                                      
                                                                          
  targetParentHandles = sf('get', targetHandles,'.linkNode.parent');  
  targetParentString =  i_find_full_path(targetParentHandles,Isa);    
                                                                          
  
  
  %
  % Find the sorted ordering   (for now just set to sequntial)
  %

  [notUsed,ordering] = sortrows(targetNames);


  displayCellArray{1} = strrows(displayCellArray{1},targetType(ordering,:));
  displayCellArray{2} = strrows(displayCellArray{2},targetNames(ordering,:));
  displayCellArray{3} = strrows(displayCellArray{3},emptyCol);
  displayCellArray{4} = strrows(displayCellArray{4},targetParentString(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},emptyCol);
  displayCellArray{6} = strrows(displayCellArray{6},emptyCol);

  sortedHandles = [sortedHandles; targetHandles(ordering)];


end




%
% Display fields for transitions
%

if ~isempty(transHandles)

  numTrans = length(transHandles);

  % Transition type display

  transType = char(ones(numTrans,1)*'Trans');

  % Find the label strings and use '|' to separate lines

  transLabel = sf('get',transHandles,'.labelString');
  transLabelStrings = i_combine_lines(transLabel);

  % Chart

  transChartHandles = sf('get', transHandles,'.chart');
  transChartNames = i_find_chart(transChartHandles);

  % Find the parents

  transParentHandles = sf('get', transHandles,'.linkNode.parent');
  transParentNames =  i_find_full_path(transParentHandles,Isa);

  % Source

  transSourceHandles = sf('get', transHandles,'.src.id');
  transSourceNames =  i_find_full_path(transSourceHandles,Isa,transParentHandles);

  % Destination

  transDestinationHandles = sf('get', transHandles,'.dst.id');
  transDestinationNames =  i_find_full_path(transDestinationHandles,Isa,transParentHandles);

  % Augment the output cell array:
 
  emptyCol = char(32*ones(numTrans,1));

  %
  % Find the sorted ordering   (for now just set to sequntial)
  %

  sortStringMat = lower([transLabelStrings(:,1:min([end 6]))  transChartNames(:,1:min([end 6])) ...
    transParentNames(:,1:min([end 6]))]);

  
  [notUsed,ordering] = sortrows(sortStringMat);

  %displayCellArray = [displayCellArray; ...
  %  transTypeCell(ordering) transLabelCell(ordering) transChartCell(ordering) ...
  %  transParentCell(ordering) transSourceCell(ordering) transDestinationCell(ordering)];

  displayCellArray{1} = strrows(displayCellArray{1},transType);
  displayCellArray{2} = strrows(displayCellArray{2},transLabelStrings(ordering,:));
  displayCellArray{3} = strrows(displayCellArray{3},transChartNames(ordering,:));
  displayCellArray{4} = strrows(displayCellArray{4},transParentNames(ordering,:));
  displayCellArray{5} = strrows(displayCellArray{5},transSourceNames(ordering,:));
  displayCellArray{6} = strrows(displayCellArray{6},transDestinationNames(ordering,:));

  sortedHandles = [sortedHandles; transHandles(ordering)];

 end


 %
 % Remove the first rows since they contained contained junk:
 %

 sz = size(displayCellArray{1});
 nrows = sz(1);

 for k=1:6
   displayCellArray{k} = displayCellArray{k}(2:nrows,:);
 end
 
%******************************************************************************
% Function - Combine lines using a specified separator.                     ***
%******************************************************************************
function outSingleLineMat = i_combine_lines(multiLineStrings),

% Effectively remove text after the first line by replacing
% all characters including and after a caraige return by spaces. (WJA 5-20-98)

[crRows,crCols] = find(multiLineStrings==10);
outSingleLineMat = multiLineStrings;
for i=1:length(crRows)
	outSingleLineMat(crRows(i),crCols(i):end) = ' ';
end

%******************************************************************************
% Function - Build the full path from a vector of Stateflow handle.         ***
%                                                                           ***
% An optional third arguement builds the path with a given termination.     ***
%******************************************************************************
function fullPath = i_find_full_path(inputHandles,isa,parHandles);

chartLevelEntry = '/';
parLevelEntry = '~.';

% Initilization
fullPath = '';


% Loop through Handles
for k = 1:length(inputHandles),
  if (inputHandles(k)>0)

    if(sf('get',inputHandles(k),'.isa')== isa.junct),  % Object is a junction

          jnctLabelString =     sf('get', inputHandles(k),'.labelString');
          jncIdent = stradd('Junct(',jnctLabelString,')');
          jncParent = sf('get', inputHandles(k),'.linkNode.parent');
          if(nargin >2)
            if (jncParent==parHandles(k)),
                  fullPath = strrows(fullPath,[parLevelEntry jncIdent]);
                else
                  pathname = sf('FullNameOf',jncParent,parHandles(k),'.');
                  fullPath = strrows(fullPath,[parLevelEntry pathname '.' jncIdent]);
                end
          else
                if (sf('get',jncParent,'.isa') == isa.chart) % See if handle is a valid chart
                  fullPath = strrows(fullPath,[chartLevelEntry jncIdent]);
                else
                  chart = sf('get',jncParent,'.chart');
                  pathname = sf('FullNameOf',jncParent,chart,'.');
                  fullPath = strrows(fullPath,[chartLevelEntry pathname '.' jncIdent]);
                end
          end

    elseif(sf('get',inputHandles(k),'.isa')== isa.machine),  % Object is a junction
		machineName = sf('get',inputHandles(k),'machine.name');
		fullPath = strrows(fullPath, machineName); % Just tack on the machine name here -JRT

    else    % Object is a state or chart

          if(nargin >2)
            if (inputHandles(k)==parHandles(k)),
                  fullPath = strrows(fullPath,parLevelEntry);
                else
                  pathname = sf('FullNameOf',inputHandles(k),parHandles(k),'.');
                  fullPath = strrows(fullPath,[parLevelEntry pathname]);
                end
          else

                if (sf('get',inputHandles(k),'.isa') == isa.chart)      % See if handle is a valid chart
                  fullPath = strrows(fullPath,chartLevelEntry);
                else
                  chart = sf('get',inputHandles(k),'.chart');
                  pathname = sf('FullNameOf',inputHandles(k),chart,'.');
                  fullPath = strrows(fullPath,[chartLevelEntry pathname]);
                end
          end
    end
  else
          fullPath = strrows(fullPath,' ');
  end
end

% Remove the first line from the cell array since it was junk
szeCell = size(fullPath);
fullPath = fullPath(2:szeCell(1),:);


%******************************************************************************
% Function - Build the chart name matrix from a vector of handles.          ***
%                                                                           ***
%******************************************************************************
function chartNames = i_find_chart(chartHandles)

if isempty(chartHandles) 
	chartNames = '';
	return;
end;

if all(chartHandles == 0),
	chartNames = ' ';
	chartNames = chartNames(ones(size(chartHandles)),:);
	return;
end;

[ordHandes,order] = sortrows(chartHandles);  

chartChange = find([-1;ordHandes]~=[ordHandes;ordHandes(end)]);

numHand = length(ordHandes);


if(length(chartChange)>1)
        instancePerChart = [chartChange(2:end);numHand+1]-chartChange;
else
        instancePerChart = numHand;
end

chrtName = sf('get',ordHandes,'.name');

% Set the first chartName to ' ' if any chart ordered handles == 0
if any(ordHandes == 0), chrtName = strrows(' ', chrtName); end;

ordNames = char(ones(instancePerChart(1),1)*chrtName(1,:));

for k=2:length(instancePerChart),
  newRows = char(ones(instancePerChart(k),1)*chrtName(k,:));
  ordNames = strrows(ordNames,newRows);
end

chartNames(order,:) =   ordNames;


function out = sf_srch(in1,in2),
%OUT = SF_SRCH( IN1, IN2 )  Function to perform the search

%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:59:49 $

   out = i_perform_search(in1,in2);

function resultHandles = i_perform_search(searchCriteria,searchSpace)

% Property cell arrays (for finding strings)

sfNames = {'state.name','data.name','event.name','chart.name'};
sfLabels = {'state.labelString','transition.labelString',...
             'junction.labelString',};
sfDescription = '.description';



% First the search should be narrowed by string

if ~isempty(searchCriteria.string)

  switch searchCriteria.searchMethod
    case 2,
      sfStringMethod = 'find';
    otherwise,
      sfStringMethod = 'regexp';
  end

  switch searchCriteria.stringLocation
  
    case 2,  % Search the labels
	  numSearchPairs = length(sfLabels);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfLabels;
	  searchPairs(2:2:(2*numSearchPairs)) = ...
	    {searchCriteria.string};
	  searchSpace = sf(sfStringMethod, ...
	    searchSpace, searchPairs{:});

    case 3,  % Search the names
	  numSearchPairs = length(sfNames);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfNames;
	  searchPairs(2:2:(2*numSearchPairs)) = ...
	    {searchCriteria.string};
	  searchSpace = sf(sfStringMethod, ...
	    searchSpace, searchPairs{:});

    case 4,  % Search the descriptions
 	  searchSpace = sf(sfStringMethod, ...
	    searchSpace, '.description', searchCriteria.string);

    otherwise,  % Search everywhere
	  % Find label matches
	  numSearchPairs = length(sfLabels);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfLabels;
	  searchPairs(2:2:(2*numSearchPairs)) = ...
	    {searchCriteria.string};
	  searchSpace1 = sf(sfStringMethod, ...
	    searchSpace, searchPairs{:});

	  % Find description matches
 	  searchSpace2 = sf(sfStringMethod, ...
	    searchSpace, '.description', searchCriteria.string);
   

   
	  % Find the union of both searches
	  searchSpace = vset(searchSpace1 ,'+',searchSpace2);

  end
  
end

%
% Now narrow the search space by object type
%

objectTypeNames = {'state.id', ...
                'transition.id', ...
                'junction.id', ...
                'event.id', ...
                'data.id'};

spaceMat = sf('get',searchSpace, ...
   objectTypeNames{find(searchCriteria.type(1:5))});

% Roll up the results:
dims = size(spaceMat);
spaceVect = spaceMat(1:prod(dims));
resultHandles = spaceVect(find(spaceVect));	% Get rid of zero elements

 


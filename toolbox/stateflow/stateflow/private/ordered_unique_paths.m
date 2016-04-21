function orderedList = ordered_unique_paths(orderedList)
%
% orderedList must be a cell array of strings. This function gets rid of duplicate
% paths while preserving the original order of unique elements. Also note that
% on PC platforms paths are case insensitive. At the same time Simulink saves PC
% drive letters of absolute paths in uppercase format. This is inconsistent with pwd
% function. So to remove any abmiguity on PC we return all paths in lower case form.
%

% Copyright 2004 The MathWorks, Inc.

	if ispc
		orderedList = lower(orderedList);
		for i=1:length(orderedList)
			if (length(orderedList{i}) > 0) && (orderedList{i}(end)=='\')
				% if this is the root of a drive, then get rid of the
				% trailing \ since it causes compilation failures
				% G76510
				orderedList{i}=orderedList{i}(1:end-1);
			end
		end
	end
	len = length(orderedList);
	if (len<=1), return; end
	reverseList = orderedList(end:-1:1);
	[l,uniqueIndx] = unique(reverseList);
	uniqueIndx = sort(len+1-uniqueIndx);
	orderedList = orderedList(uniqueIndx);

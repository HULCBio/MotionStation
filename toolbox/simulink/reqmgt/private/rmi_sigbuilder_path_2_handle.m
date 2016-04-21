function [blockHandle, groupIndex] = rmi_sigbuilder_path_2_handle(pathName)

% Copyright 2004 The MathWorks, Inc.

	% Assume not valid signal builder path
	blockHandle = -1;
	groupIndex  = -1;

	% Break into tokens
	tokens = regexp(pathName, '([^/]|(//)+)*', 'match');
	count  = length(tokens);

	if count >= 2
		% Decompose into block path and tab name
		groupName    = tokens{count};
		groupNameLen = length(groupName);
		pathNameLen  = length(pathName)
		blockName    = pathName(1:(pathNameLen - groupNameLen - 1));

		if is_signal_builder_block(blockName)
			% Get group labels
			[time, data, siglabels, grouplabels] = signalbuilder(blockName);

			% See if proposed group name is found.  We know group
			% names are unique so this will either have one index
			% or be empty.
			index = find(strcmp(grouplabels(:), groupName));
			if ~isempty(index)
				blockHandle = get_param(blockName, 'handle');
				groupIndex  = index;
			end;
		end;
	end;
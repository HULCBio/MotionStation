function filePath = locate_file(doc, modelName)
%LOCATE_FILE - Common utility for finding the full path 
%              to a file based a potentially limited path.
%

% Copyright 2004 The MathWorks, Inc.

	% Guard against handle being passed in
	if ishandle(modelName)
		modelName = get_param(modelName, 'Name');
	end;

	whichDoc = which(doc);
	if ~isempty(whichDoc)
		doc = whichDoc;
	elseif ~exist(doc,'file')
		% Get model file name
		fileName = which(modelName);

		% Break apart file name into parts
		[pathStr, nameStr, extStr, versionStr] = fileparts(fileName);

		% Append doc to model path
		doc = fullfile(pathStr, doc);
	end;

	if ~exist(doc)
        filePath = '';
    else
	    filePath = doc;
	end


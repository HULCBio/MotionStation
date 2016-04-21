function result = RMIHist(method, varargin)

% Copyright 2004 The MathWorks, Inc.

	persistent histData;

	% Cache variable arguement size
	nvarargin = length(varargin);

	switch lower(method)
	case 'add'

		switch nvarargin
		case 1
			histData = addHist(histData, varargin{1});
		otherwise
			error('Invalid number of arguments');
		end;

	case 'get'
		histData = getHist(histData);
	otherwise
		error('Unknown method');
	end;
	
	result = histData;


function histData = addHist(histData, filename)

	% If no history, filename becomes history
	if isempty(histData)
		histData = {filename};

	% We have some history
	else
		loc = strcmp(histData, filename);
		loc = find(loc > 0);

		% Found in history, swap with front
		if ~isempty(loc)
			histData(loc) = [];
			histData      = {filename histData{:}};

		% Not found in history, prepend
		else
			histData = {filename histData{:}};
		end;
	end;

	% Limit length of history
	histLen = 5;
	if length(histData) > histLen
		histData(histLen+1 : length(histData)) = [];
	end;

	% Commit history
	try
		histFileName = getHistFileName();
		save(histFileName, 'histData', '-mat');
	catch
	end;

function histData = getHist(histData)

	if isempty(histData)
		% Assume no history found
		histData = {};

		% Cache name of history file
		histFileName = getHistFileName();

		% Get existing history
		if exist(histFileName)
			histFileStruct = load(histFileName);
			if isfield(histFileStruct, 'histData')
				histData = histFileStruct.histData;
			end;
		end;
	end


function result = getHistFileName();

	result = fullfile(prefdir, 'RMIHistData.mat');
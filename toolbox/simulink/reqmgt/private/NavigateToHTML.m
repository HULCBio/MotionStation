function NavigateToHTML(filename, id)

% Copyright 2004 The MathWorks, Inc.

	% Resolve url
	url = filename;
	if ~isempty(id)
		url = [url '#' id];
	end;

	% Open in browser
	web(url);
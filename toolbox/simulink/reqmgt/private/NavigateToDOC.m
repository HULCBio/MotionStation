function NavigateToDOC(filename, id)

% Copyright 2004 The MathWorks, Inc.

	persistent hWord;

	% Open if not opened yet
	if isempty(hWord) || ~isServerValid(hWord)
		hWord = actxserver('word.application');
	end;

	% Force to be visible
	hWord.visible = 1;

	% Open
	hDocs = hWord.documents;
	hDocs.Open(filename, [], 1);

	% Find text
	if ~isempty(id)
		hWord.Selection.Find.Text = id;
		hWord.Selection.Find.Execute;
	end;

function result = isServerValid(hWord)

	result = 1;
	try
		hWord.visible = 1;
	catch
		result = 0;
	end;
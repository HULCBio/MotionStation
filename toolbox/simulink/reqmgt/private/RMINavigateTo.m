function RMINavigateTo(model, doc, id)

% Copyright 2004 The MathWorks, Inc.

	% Get model handle
	modelName = model;
	if ishandle(modelName)
		modelName = get_param(modelName, 'Name');
	end;

	% Validate document location
	doc = locate_file(doc, modelName);

	% Determine type of document we have
	docType = RMIDocType(doc);

	% Navigate
	switch docType
	case 'TXT'
		NavigateToTXT(doc, id);
	case 'HTML'
		NavigateToHTML(doc, id);
	case 'WORD'
		NavigateToDOC(doc, id);
	case 'EXCEL'
		NavigateToXLS(doc, id);
	end;
function NavigateToXLS(filename, id)

% Copyright 2004 The MathWorks, Inc.

	persistent hExcel;

	% Open if not opened yet
	if isempty(hExcel) || ~isServerValid(hExcel)
		hExcel = actxserver('excel.application');
	end;

	% Force to be visible
	hExcel.visible = 1;

	% Open
	hWorkbooks = hExcel.workbooks;
	hWorkbook  = hWorkbooks.Open(filename, [], 1);

	% Find text
	if ~isempty(id)
		hSheets   = hWorkbook.sheets;
		hSheet    = hSheets.Item(1);
		hRange    = hSheet.Range('A1:IV20000');
		hSelRange = hRange.Find(id);
		if ~isempty(hSelRange)
			hSelRange.Select;
		end;
	end;


function result = isServerValid(hExcel)

	result = 1;
	try
		hExcel.visible = 1;
	catch
		result = 0;
	end;	
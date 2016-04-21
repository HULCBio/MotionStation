function result = resolve_com_doors()

% Copyright 2004 The MathWorks, Inc.

	persistent hDOORS;

	% Create COM object
	if isempty(hDOORS) || ~isServerValid(hDOORS)
		try
			hDOORS = actxserver('DOORS.Application');
		catch
			hDOORS = [];
			error('Error connecting to DOORS');
		end;
	end;

	result = hDOORS;


function result = isServerValid(hDOORS)

	result = 1;
	try
		hDOORS.runStr('');
	catch
		result = 0;
	end;
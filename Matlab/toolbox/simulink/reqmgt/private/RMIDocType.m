function result = RMIDocType(filename)

% Copyright 2004 The MathWorks, Inc.

	result = 'HTML';

	[pathStr, nameStr, extStr, versnStr] = fileparts(filename);

	switch lower(extStr)
	case {'.txt'}
		result = 'TXT';
	case {'.htm', '.html', '.asp', '.stm'}
		result = 'HTML';
	case {'.doc'}
		result = 'WORD';
	case {'.xls', '.csv'}
		result = 'EXCEL';
	end;

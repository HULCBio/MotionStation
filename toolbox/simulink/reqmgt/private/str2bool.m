function result = str2bool(str)

% Copyright 2004 The MathWorks, Inc.

	if strcmp(str, 'true')
		result = 1;
	else
		result = 0;
	end;

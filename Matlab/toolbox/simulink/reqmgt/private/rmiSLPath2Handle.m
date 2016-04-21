function result = rmiSLPath2Handle(slPathName)

% Copyright 2004 The MathWorks, Inc.

	% Assume path invalid
	result = -1;

	try
		result = get_param(slPathName, 'handle');
	catch
		result = -1;
	end;
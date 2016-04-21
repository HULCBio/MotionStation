function result = is_doors_installed()

% Copyright 2004 The MathWorks, Inc.

	result = false;
	try
		if ispc
			% This is the DOORS support recommended way of determining
			% if DOORS is installed.  The other option is to attempt to
			% create the COM object, the disadvantage of which is it will
			% launch the DOORS and ask you to login.  If this key doesn't
			% exist, the following will error out.
			winqueryreg('name', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Telelogic\DOORS');
			result = true;
		end;
	catch
	end;
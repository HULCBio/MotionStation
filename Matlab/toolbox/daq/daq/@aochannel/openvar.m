function openvar(name, value)
%OPENVAR Workspace Broswer integration function
%
%    This function is for internal use only and should not be modified
%    as it has limited lifetime and may not work as expected in future
%    releases.

%    DK 10-25-01
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.2.2.4 $  $Date: 2003/08/29 04:40:02 $

if isvalid(value)
	if (length(value)==1)
		daqpropedit(value);
	else
		daqpropedit;
	end
else
	errordlg(['''', name, ''' is or contains an invalid object(s). Please clear from your workspace.'], 'Invalid Object', 'on');
end

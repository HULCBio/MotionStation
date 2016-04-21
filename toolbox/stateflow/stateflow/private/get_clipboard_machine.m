function clipboardId = get_clipboard_machine,
%GET_CLIPBOARD_MACHIHE

%	Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $  $Date: 2004/04/15 00:58:00 $

	clipboardId = sf('find','all','machine.name','$$Clipboard$$');
	switch(length(clipboardId)),
		case 0, 
			warning('No clipboard machine found, creating new one.');
			clipboardId = sf('new', 'machine', '.name', '$$Clipboard$$');
		case 1, return;
		otherwise, 
			warning('Multiple clipboards in memory.');
			sf('delete', clipboardId(2:end));
			clipboardId = clipboardId(1);
	end;

function explr_obj_del(id),
%EXPLR_OBJ_DEL( ID )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:39 $

	clipboardH = sf('find','all','machine.name','$$Clipboard$$');
	switch(length(clipboardH)),
		case 0, 
			warning('No clipboard machine found, creating new one.');
			clipboardH = sf('new', 'machine', '.name', '$$Clipboard$$');
		case 1,
		otherwise, 
			warning('Multiple clipboards in memory.');
			sf('delete', clipboardH(2:end));
			clipboardH = clipboardH(1);
	end;

	sf('MoveObjectToParent',id, clipboardH);


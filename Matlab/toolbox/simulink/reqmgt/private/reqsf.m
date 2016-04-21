function result = reqsf(action, model, name, itemname, str)
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/03/26 13:28:08 $

	result = '';

	% Resolve name to ID
	id = rmiSFPath2Handle(name);

	% Get/set
	if sf('ishandle', id)
		switch lower(action)
		case 'get'
			result = sf('get', id, '.requirementInfo');
		case 'set'
			sf('set', id, '.requirementInfo', str);
			result = str;
		end;
	end;

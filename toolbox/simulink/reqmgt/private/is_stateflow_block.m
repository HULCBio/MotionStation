function result = is_stateflow_block(obj)

% Copyright 2004 The MathWorks, Inc.

	result =    strcmp(get_param(obj, 'Type'),     'block')...
	         && strcmp(get_param(obj, 'MaskType'), 'Stateflow');
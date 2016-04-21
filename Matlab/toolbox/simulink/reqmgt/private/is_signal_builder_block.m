function result = is_signal_builder_block(obj)

% Copyright 2004 The MathWorks, Inc.

	result =    ~isempty(obj)...
	         && strcmp(get_param(obj, 'Type'),     'block')...
	         && strcmp(get_param(obj, 'MaskType'), 'Sigbuilder block');
function slTypeEnum = sl_type_enum_from_name(dataType)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.16.1 $  $Date: 2004/04/13 03:12:39 $

	switch(lower(dataType))
	case {'boolean','state'}
		slTypeEnum = 'SS_BOOLEAN';
	case 'uint8'
		slTypeEnum = 'SS_UINT8';
	case 'uint16'
		slTypeEnum = 'SS_UINT16';
	case 'uint32'
		slTypeEnum = 'SS_UINT32';
	case 'int8'
		slTypeEnum = 'SS_INT8';
	case 'int16'
		slTypeEnum = 'SS_INT16';
	case 'int32'
		slTypeEnum = 'SS_INT32';
	case 'single'
		slTypeEnum = 'SS_SINGLE';
	case 'double'
		slTypeEnum = 'SS_DOUBLE';
	otherwise,
		slTypeEnum = 'SS_DOUBLE';
	end

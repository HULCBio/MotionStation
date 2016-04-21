function sfTypeEnum = sf_type_enum_from_name(dataType)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2.4.1 $  $Date: 2004/04/13 03:12:39 $

	switch(lower(dataType))
	case {'boolean','state'}
		sfTypeEnum = 'SF_UINT8';
	case 'uint8'
		sfTypeEnum = 'SF_UINT8';
	case 'uint16'
		sfTypeEnum = 'SF_UINT16';
	case 'uint32'
		sfTypeEnum = 'SF_UINT32';
	case 'int8'
		sfTypeEnum = 'SF_INT8';
	case 'int16'
		sfTypeEnum = 'SF_INT16';
	case 'int32'
		sfTypeEnum = 'SF_INT32';
	case 'single'
		sfTypeEnum = 'SF_SINGLE';
	case 'double'
		sfTypeEnum = 'SF_DOUBLE';
	case 'ml'
		sfTypeEnum = 'SF_MATLAB';
	otherwise,
		sfTypeEnum = 'SF_DOUBLE';
	end

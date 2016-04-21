function dataTypeProps = rtwmath_data_type_prop_list
%DATA_TYPE_PROP_LIST - List of all data types that can reference
%  an implementation in the math library.

% Copyright 2002 The MathWorks, Inc.

    dataTypeProps = { 'double', 'single', 'int32', 'int16', 'int8', 'uint32', ...
                      'uint16', 'uint8', 'integer', 'pointer'};

                      
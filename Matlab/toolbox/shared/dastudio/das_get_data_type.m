function dt = das_get_data_type(obj, propName)

% Copyright 2004 The MathWorks, Inc.

dt = 'other';
enumVals = das_get_enum_values(obj, propName);
if (~isempty(enumVals))
    dt = 'enum';
end    

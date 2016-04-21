function enumVals = das_get_enum_values(obj, propName)

% Copyright 2004 The MathWorks, Inc.

enumVals = {};
try
    dots = strfind(propName, '.');
    if (isempty(dots))
        enumVals = set(obj, propName);
    else
        start = 1;
        currentObj = obj;
        for i=dots
            subPropName = propName(start:i-1);
            start = i+1;
            currentObj = get(currentObj, subPropName);
        end
        enumVals = set(currentObj, propName(start:end));
    end
catch
end

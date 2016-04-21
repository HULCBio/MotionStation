function utdeepcopy(h, hout)
% Copies h onto hout by calling the copy method
% on the contents of each serializable handle property.

% Copyright 2003 The MathWorks, Inc.

% This method is seperated from copy so that subclasses
% are only required to overload the constructor call (e.g.,
% the Simulink.Timeseries copy method only need overload copy
% which only creates the object to be copied into using the parent
% utdeepcopy method to perform the actual copy

% Note this method cannot be moved onto the path as a function becuase it
% needs writable properties with may be private.
c = classhandle(h);
% Build a list of properties
props = c.Properties;

for k=1:length(props)
    axflags = get(props(k),'AccessFlags');
    if strcmp(axflags.Serialize,'on')
        propval = get(h,props(k).Name);
        newpropval = propval;
        for j=1:length(propval)
            if ishandle(propval(j))
                newpropval(j) = copy(propval(j));
            end
        end
        set(hout,props(k).Name,newpropval)
    end
end

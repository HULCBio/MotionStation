function vals = tsParseInputs(argsin, props, types,defvals)
%TSPARSEINPUTS Utility function used for prop-val pair type inputs
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:36:17 $

% Parse the property-value pairs
vals = defvals;
for k=1:floor(length(argsin)/2)
    pos = strcmpi(argsin{2*k-1},props);
    if ~any(pos)
        error('tsParseInputs:noprop','Undefined property name')
    end
    thesetypes = types{pos};
    if iscell(thesetypes)
        typeerr = true;
        for j=1:length(thesetypes)
            if isa(argsin{2*k},thesetypes{j})
                typeerr = false;
            end
        end
        if typeerr
            error('tsParseInputs:typeerr',[props{pos} ' has an invalid property type'])
        end
    elseif ischar(thesetypes) && ~isa(argsin{2*k},thesetypes)      
        error(['Property value ' props{pos} ' must have type ' thesetypes]);
    end    
    vals{pos} = argsin{2*k};
end
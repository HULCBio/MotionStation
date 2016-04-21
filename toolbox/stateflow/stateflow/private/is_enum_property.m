function  ie = is_enum_property(obj, propName)

% Copyright 2003-2004 The MathWorks, Inc.

clsName = get(classhandle(obj), 'Name');

switch (clsName)
    case 'Data'
        ie = data_is_enum_l(obj, propName);
    case 'Event'
        ie = event_is_enum_l(obj, propName);
    otherwise
        ie = default_is_enum_l(obj, propName);      
end




function ie = data_is_enum_l(obj, propName)
switch propName
    case 'Port'        
        ie = logical(1);
        
    otherwise
        ie = default_is_enum_l(obj, propName);
end

function ie = event_is_enum_l(obj, propName)
switch propName
    case 'Port'        
        ie = logical(1);
        
    otherwise
        ie = default_is_enum_l(obj, propName);
end


function ie = default_is_enum_l(obj, propName)

ie = logical(0);
try
    enumVals = set(obj, propName);
    if (~isempty(enumVals))
        ie = logical(1);
    end    
catch   
end 



    


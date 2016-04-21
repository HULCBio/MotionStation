function success = change_de_port_index(de, newIndex)

% Copyright 2003 The MathWorks, Inc.

success = logical(0);

validPortStr = get_valid_property_values(de, 'Port');
isValid = logical(0);
if(isequal(newIndex, str2num(validPortStr{1})))
    newIndex = 1;  % code for "first of its kind"
    isValid = logical(1);
else 
    for i=2:length(validPortStr)
        if (isequal(newIndex, str2num(validPortStr{i})))
            isValid = logical(1);
            break;
        end
    end
end

if (~isValid)
    return;
end


try
    oldIndex = de.Port;

    if (isequal(oldIndex, newIndex))
        success = logical(1); % okay to "change" to same value
        return;
    elseif (oldIndex<newIndex)
        % moving up
        prevNum = newIndex;
    else
        % moving down
        prevNum = newIndex-1;
    end
    

    if (isequal(newIndex, 1))
        appendId = 0;
    else
        appendObj = find(de.up, '-depth', 1, ...
            'Scope', de.Scope, ...
            'Port', prevNum ...
            );              
        appendId = appendObj.id;
    end
    
    sf('MoveObjectAfterLink', de.id, appendId);
    success = logical(1);
    
catch
end

    

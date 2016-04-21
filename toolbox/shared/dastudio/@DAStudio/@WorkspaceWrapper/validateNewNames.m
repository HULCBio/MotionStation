function valid = validateNewNames(h, names)

    valid = {};

    if (isempty(h.wrappedWorkspace))
        ws = 'base';
    else
        ws = h.wrappedWorkspace;
    end

    for i=1:length(names)
        valid{i} = '';
        if (isvarname(names{i}))
            index = 0;
            name = names{i};
            while(isempty(valid{i}))
                if evalin(ws, ['exist(''' name ''', ''var'')']) | any(strcmp(valid, name))
                    index = index + 1;
                    name = [names{i} num2Str(index)];
                else
                    valid{i} = name;
                end
            end
        end
    end,


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:41 $

function RHS = value2RHS(value)
% Convert a value into a valid matlab expression.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2004/01/16 16:51:09 $

% Now, many people musy have needed something like this.
% Is there one of these for general use?

if(length(value) == 1)
    if(isa(value,'function_handle'))
        RHS = func2str(value);
        RHS = ['@' RHS];
    elseif(isnumeric(value))
        RHS = num2str(value);
    elseif(ischar(value))
        RHS = ['''' value ''''];
    elseif(iscell(value))
        RHS = ['{ ', value2RHS(value{1}) ' }'];
    elseif(isa(value,'inline'))
        RHS = ['inline('''  char(value)  ''')'];
    elseif (isa(value,'struct'))
        RHS = '<userStructure>';
    elseif isobject(value)
        RHS = '<userClass>';
    else
        RHS = '<userData>';
    end
elseif(length(value) > 1)
    if(isnumeric(value))
        RHS = '[';
        [r, c] = size(value);
        for i = 1:r
            RHS = [RHS, num2str(value(i,:))];
            if i~=r
                RHS = [RHS , ' ; '];
            end    
        end
        RHS = [ RHS ' ]' ];
    elseif(iscell(value))
        RHS = '{';
        for i = 1:length(value)
            RHS = [RHS, ' ', value2RHS(value{i}) ];
        end
        RHS = [ RHS ' }' ];
    elseif size(value,1) == 1 % it must be a string!
        RHS = ['''' value ''''];
    elseif (isa(value,'struct'))
        RHS = '<userStructure>';
    elseif isobject(value)
        RHS = '<userClass>';
    else
        RHS = '<userData>';
    end
else % it's empty!
    RHS = '[]';
end

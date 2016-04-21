function newMsg = commblkmint(block,ID)
% Mask Helper function.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:29 $

lastErr = sllasterror;
emsg    = lastErr.Message;

newMsg = '';
if(findstr(emsg,'Exclude Full Matrix'))
    newMsg = 'Input must be a vector or scalar..';
elseif(findstr(emsg,'Exclude Frame-based Input'))
    newMsg = 'Input must be sample-based..';
end;

if(isempty(newMsg))
    key = 'MATLAB error message:';
    idx = min(findstr(emsg, key));

    if(isempty(idx))
        key = ':';
        idx = min(findstr(emsg, key));
    end;

    if(isempty(idx))
        newMsg = emsg;
    else
        newMsg = emsg(idx+length(key):end);
    end;

end;

return;

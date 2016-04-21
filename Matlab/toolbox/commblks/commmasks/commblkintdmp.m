function newMsg = commblkintdmp(block,ID)
% Mask Helper function.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/03/24 02:01:37 $

lastErr = sllasterror;
emsg    = lastErr.Message;
newMsg  = '';

if(findstr(emsg,'Exclude Full Matrix'))
    newMsg = 'Input must be a vector or scalar..';
elseif(findstr(emsg,'Exclude Frame-based Input'))
    newMsg = 'Frame-based inputs must be row vectors..';
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


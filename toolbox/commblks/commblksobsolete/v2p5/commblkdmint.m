function newMsg = commblkdmint(block,ID)
% Mask Helper function.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:27 $

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

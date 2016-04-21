function audiouniquename(var, name, ws)
% AUDIOUNIQUENAME Assign unique variable name in workspace.
%
%   This function is a helper for toolbox/matlab/audiovideo/prefspanel.m
%   and other workspace browser context menu functionality.  It is 
%   unsupported and calls to this function may become errors in future 
%   releases.
%
%   AUDIOUNIQUENAME(VAR, NAME, WS) gives variable VAR name NAME in 
%   workspace WS.  WS is 'caller' by default.  If a variable with name 
%   NAME already exists in workspace WS, a number is appended to the 
%   desired variable name.

%   Author: B. Wherry
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:41 $

error(nargchk(2,3,nargin));

if ~ ischar(name),
    error('Second parameter to audiouniquename must be a string');
end

if nargin == 2,
    ws = 'caller';
end

% First see if that variable is in the workspace already.
teststring = sprintf('exist(''%s'');',name);
if ~ evalin(ws, teststring),
    % It's not in the workspace, so just assign it and leave.
    assignin(ws, name, var);
    return;
end

% That variable is in the workspace, so we now add a number to 
% the end of name until it's unique.
count = 1;
while 1,
    newname = strcat(name, num2str(count));
    teststring = sprintf('exist(''%s'');',newname);
    if ~ evalin(ws, teststring),
        % We found it!
        assignin(ws, newname, var);
        break;
    else
        count = count + 1;
    end
end

% [EOF]